import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/core/network/api_exception.dart';
import 'package:profesionalservis_mobile/features/customer/data/models/customer_model.dart';
import 'package:profesionalservis_mobile/features/pos/data/models/pos_cart_item.dart';
import 'package:profesionalservis_mobile/features/pos/data/models/receipt_payload_model.dart';
import 'package:profesionalservis_mobile/features/pos/data/repositories/receipt_repository.dart';
import 'package:profesionalservis_mobile/features/pos/data/repositories/transaction_repository.dart';
import 'package:profesionalservis_mobile/features/product/data/models/product_model.dart';
import 'package:profesionalservis_mobile/features/product/data/repositories/product_repository.dart';
import 'package:profesionalservis_mobile/features/transaction/data/models/transaction_model.dart';

final posProvider = StateNotifierProvider<PosNotifier, PosState>((ref) {
  final notifier = PosNotifier(
    productRepository: ref.watch(productRepositoryProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
    receiptRepository: ref.watch(receiptRepositoryProvider),
  );
  notifier.loadProducts();
  ref.onDispose(notifier.dispose);
  return notifier;
});

enum PosPaymentMethod { cash, transfer, eWallet }

extension PosPaymentMethodX on PosPaymentMethod {
  String get label => switch (this) {
        PosPaymentMethod.cash => 'Tunai',
        PosPaymentMethod.transfer => 'Transfer',
        PosPaymentMethod.eWallet => 'QRIS / E-Wallet',
      };

  String get apiValue => switch (this) {
        PosPaymentMethod.cash => 'cash',
        PosPaymentMethod.transfer => 'transfer',
        PosPaymentMethod.eWallet => 'e-wallet',
      };
}

class PosHeldOrder {
  const PosHeldOrder({
    required this.holdNumber,
    required this.items,
    required this.createdAt,
  });

  final String holdNumber;
  final List<PosCartItem> items;
  final DateTime createdAt;

  int get totalItems => items.fold<int>(0, (sum, item) => sum + item.quantity);
  int get subtotal => items.fold<int>(0, (sum, item) => sum + item.lineTotal);
}

class PosCheckoutResult {
  const PosCheckoutResult({
    required this.invoice,
    required this.subtotal,
    required this.discount,
    required this.taxPercent,
    required this.taxAmount,
    required this.total,
    required this.paidAmount,
    required this.change,
    required this.paymentMethod,
    required this.items,
    required this.createdAt,
    required this.raw,
  });

  final String invoice;
  final int subtotal;
  final int discount;
  final double taxPercent;
  final int taxAmount;
  final int total;
  final int paidAmount;
  final int change;
  final PosPaymentMethod paymentMethod;
  final List<PosCartItem> items;
  final DateTime createdAt;
  final Map<String, dynamic> raw;
}

class PosState {
  const PosState({
    this.products = const [],
    this.filteredProducts = const [],
    this.cartItems = const [],
    this.selectedCustomer,
    this.selectedPaymentMethod = PosPaymentMethod.cash,
    this.discountAmount = 0,
    this.taxPercent = 0,
    this.paidAmount = 0,
    this.holdOrders = const [],
    this.search = '',
    this.selectedBranch = 'Cabang Pusat',
    this.isLoadingProducts = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.lastHoldNumber,
    this.checkoutResult,
    this.lastPaidTransaction,
    this.lastReceiptPayload,
  });

  final List<ProductModel> products;
  final List<ProductModel> filteredProducts;
  final List<PosCartItem> cartItems;
  final CustomerModel? selectedCustomer;
  final PosPaymentMethod selectedPaymentMethod;
  final double discountAmount;
  final double taxPercent;
  final double paidAmount;
  final List<PosHeldOrder> holdOrders;
  final String search;
  final String selectedBranch;
  final bool isLoadingProducts;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final String? lastHoldNumber;
  final PosCheckoutResult? checkoutResult;
  final TransactionModel? lastPaidTransaction;
  final ReceiptPayloadModel? lastReceiptPayload;

  // Backward-compatible aliases for older widgets in this repository.
  Map<String, List<PosCartItem>> get heldCarts => {
        for (final order in holdOrders) order.holdNumber: order.items,
      };
  bool get isSubmittingCheckout => isSubmitting;
  String get selectedPaymentMethodLabel => selectedPaymentMethod.label;

  int get subtotal => cartItems.fold<int>(0, (sum, item) => sum + item.lineTotal);
  int get discount => discountAmount.round().clamp(0, subtotal);
  int get totalBeforeTax => max(subtotal - discount, 0);
  int get taxAmount => (totalBeforeTax * taxPercent / 100).round();
  int get total => max(totalBeforeTax + taxAmount, 0);
  int get changeAmount => max(paidAmount.round() - total, 0);
  int get effectivePaidAmount {
    if (selectedPaymentMethod == PosPaymentMethod.cash) {
      return paidAmount.round();
    }
    return paidAmount <= 0 ? total : paidAmount.round();
  }

  PosState copyWith({
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
    List<PosCartItem>? cartItems,
    CustomerModel? selectedCustomer,
    bool clearSelectedCustomer = false,
    PosPaymentMethod? selectedPaymentMethod,
    double? discountAmount,
    double? taxPercent,
    double? paidAmount,
    List<PosHeldOrder>? holdOrders,
    String? search,
    String? selectedBranch,
    bool? isLoadingProducts,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
    String? lastHoldNumber,
    bool clearLastHoldNumber = false,
    PosCheckoutResult? checkoutResult,
    bool clearCheckoutResult = false,
    TransactionModel? lastPaidTransaction,
    bool clearLastPaidTransaction = false,
    ReceiptPayloadModel? lastReceiptPayload,
    bool clearLastReceiptPayload = false,
  }) {
    return PosState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      cartItems: cartItems ?? this.cartItems,
      selectedCustomer: clearSelectedCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      discountAmount: discountAmount ?? this.discountAmount,
      taxPercent: taxPercent ?? this.taxPercent,
      paidAmount: paidAmount ?? this.paidAmount,
      holdOrders: holdOrders ?? this.holdOrders,
      search: search ?? this.search,
      selectedBranch: _safeText(selectedBranch ?? this.selectedBranch, 'Cabang Pusat'),
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      lastHoldNumber: clearLastHoldNumber ? null : (lastHoldNumber ?? this.lastHoldNumber),
      checkoutResult: clearCheckoutResult ? null : (checkoutResult ?? this.checkoutResult),
      lastPaidTransaction: clearLastPaidTransaction ? null : (lastPaidTransaction ?? this.lastPaidTransaction),
      lastReceiptPayload: clearLastReceiptPayload ? null : (lastReceiptPayload ?? this.lastReceiptPayload),
    );
  }

  static String _safeText(String value, String fallback) {
    final text = value.trim();
    return text.isEmpty ? fallback : text;
  }
}

class PosNotifier extends StateNotifier<PosState> {
  PosNotifier({
    required ProductRepository productRepository,
    required TransactionRepository transactionRepository,
    required ReceiptRepository receiptRepository,
  })  : _productRepository = productRepository,
        _transactionRepository = transactionRepository,
        _receiptRepository = receiptRepository,
        super(const PosState());

  final ProductRepository _productRepository;
  final TransactionRepository _transactionRepository;
  final ReceiptRepository _receiptRepository;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoadingProducts: true, clearErrorMessage: true);
    try {
      final response = await _productRepository.getProducts(page: 1, search: state.search);
      final products = response.data.map(_safeProduct).toList(growable: false);
      state = state.copyWith(
        products: products,
        filteredProducts: products,
        isLoadingProducts: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingProducts: false,
        errorMessage: 'Gagal memuat produk POS.',
      );
    }
  }

  ProductModel _safeProduct(ProductModel product) {
    return product.copyWith(
      name: product.name.trim().isEmpty ? '-' : product.name.trim(),
      price: product.price < 0 ? 0 : product.price,
      stock: product.stock < 0 ? 0 : product.stock,
      category: product.category.trim().isEmpty ? 'Umum' : product.category.trim(),
    );
  }

  void consumeMessages() {
    state = state.copyWith(
      clearErrorMessage: true,
      clearSuccessMessage: true,
      clearLastHoldNumber: true,
    );
  }

  void setSearch(String value) {
    state = state.copyWith(search: value, clearCheckoutResult: true);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), loadProducts);
  }

  void addToCart(ProductModel product) {
    final index = state.cartItems.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      state = state.copyWith(
        cartItems: [...state.cartItems, PosCartItem(product: product)],
        paidAmount: _paidAmountAfterCartChange([...state.cartItems, PosCartItem(product: product)]),
        clearCheckoutResult: true,
        clearSuccessMessage: true,
      );
      return;
    }

    final current = state.cartItems[index];
    final updated = [...state.cartItems]..[index] = current.copyWith(quantity: current.quantity + 1);
    state = state.copyWith(
      cartItems: updated,
      paidAmount: _paidAmountAfterCartChange(updated),
      clearCheckoutResult: true,
      clearSuccessMessage: true,
    );
  }

  double _paidAmountAfterCartChange(List<PosCartItem> items) {
    if (state.selectedPaymentMethod == PosPaymentMethod.cash) {
      return state.paidAmount;
    }
    final subtotal = items.fold<int>(0, (sum, item) => sum + item.lineTotal);
    final discount = state.discountAmount.round().clamp(0, subtotal);
    final beforeTax = max(subtotal - discount, 0);
    final tax = (beforeTax * state.taxPercent / 100).round();
    return (beforeTax + tax).toDouble();
  }

  void updateQuantity({required String productId, required int quantity}) {
    final safeQty = quantity < 1 ? 1 : quantity;
    final updated = state.cartItems
        .map((item) => item.product.id == productId ? item.copyWith(quantity: safeQty) : item)
        .toList(growable: false);
    state = state.copyWith(
      cartItems: updated,
      paidAmount: _paidAmountAfterCartChange(updated),
      clearCheckoutResult: true,
    );
  }

  void updateDiscount({required String productId, required int discount}) {
    final updated = state.cartItems
        .map((item) {
          if (item.product.id != productId) return item;
          final maxDiscount = item.lineBaseTotal;
          final safeDiscount = discount.clamp(0, maxDiscount);
          return item.copyWith(discount: safeDiscount);
        })
        .toList(growable: false);
    state = state.copyWith(
      cartItems: updated,
      paidAmount: _paidAmountAfterCartChange(updated),
      clearCheckoutResult: true,
    );
  }

  void removeItem(String productId) {
    final updated = state.cartItems.where((item) => item.product.id != productId).toList(growable: false);
    state = state.copyWith(
      cartItems: updated,
      paidAmount: _paidAmountAfterCartChange(updated),
      clearCheckoutResult: true,
    );
  }

  void setSelectedCustomer(CustomerModel? customer) {
    state = state.copyWith(
      selectedCustomer: customer,
      clearSelectedCustomer: customer == null,
      clearCheckoutResult: true,
    );
  }

  void setPaymentMethod(PosPaymentMethod method) {
    final shouldAutoFill = method != PosPaymentMethod.cash || state.paidAmount <= 0;
    state = state.copyWith(
      selectedPaymentMethod: method,
      paidAmount: shouldAutoFill ? state.total.toDouble() : state.paidAmount,
      clearCheckoutResult: true,
    );
  }

  void setPaymentMethodByLabel(String value) {
    final text = value.trim().toLowerCase();
    if (text.contains('transfer') || text.contains('debit')) {
      setPaymentMethod(PosPaymentMethod.transfer);
      return;
    }
    if (text.contains('qris') || text.contains('wallet')) {
      setPaymentMethod(PosPaymentMethod.eWallet);
      return;
    }
    setPaymentMethod(PosPaymentMethod.cash);
  }

  void setBranch(String value) {
    state = state.copyWith(selectedBranch: value, clearCheckoutResult: true);
  }

  void setTaxPercent(num value) {
    final nextTax = value.toDouble().clamp(0, 15).toDouble();
    state = state.copyWith(
      taxPercent: nextTax,
      paidAmount: state.selectedPaymentMethod == PosPaymentMethod.cash ? state.paidAmount : _totalForTax(nextTax).toDouble(),
      clearCheckoutResult: true,
    );
  }

  int _totalForTax(double taxPercent) {
    final subtotal = state.subtotal;
    final discount = state.discountAmount.round().clamp(0, subtotal);
    final beforeTax = max(subtotal - discount, 0);
    return beforeTax + (beforeTax * taxPercent / 100).round();
  }

  void setDiscountAmount(num value) {
    final discount = value.toDouble().clamp(0, state.subtotal).toDouble();
    state = state.copyWith(
      discountAmount: discount,
      paidAmount: state.selectedPaymentMethod == PosPaymentMethod.cash ? state.paidAmount : _totalForDiscount(discount).toDouble(),
      clearCheckoutResult: true,
    );
  }

  int _totalForDiscount(double discountAmount) {
    final subtotal = state.subtotal;
    final discount = discountAmount.round().clamp(0, subtotal);
    final beforeTax = max(subtotal - discount, 0);
    return beforeTax + (beforeTax * state.taxPercent / 100).round();
  }

  void setPaidAmount(num value) {
    state = state.copyWith(paidAmount: max(value.toDouble(), 0), clearCheckoutResult: true);
  }

  String? holdCart() {
    if (state.cartItems.isEmpty) {
      state = state.copyWith(errorMessage: 'Keranjang masih kosong.');
      return null;
    }

    final now = DateTime.now();
    final holdNumber = _formatHoldNumber(now);
    final heldOrder = PosHeldOrder(
      holdNumber: holdNumber,
      items: [...state.cartItems],
      createdAt: now,
    );

    // TODO: Replace local held order with backend hold-order endpoint when available.
    state = state.copyWith(
      holdOrders: [heldOrder, ...state.holdOrders],
      cartItems: const [],
      paidAmount: 0,
      lastHoldNumber: holdNumber,
      successMessage: 'Keranjang disimpan sebagai $holdNumber.',
      clearCheckoutResult: true,
      clearErrorMessage: true,
    );
    return holdNumber;
  }

  void resumeCart(String holdNumber) {
    PosHeldOrder? selected;
    for (final order in state.holdOrders) {
      if (order.holdNumber == holdNumber) {
        selected = order;
        break;
      }
    }
    if (selected == null) return;

    final held = state.holdOrders.where((order) => order.holdNumber != holdNumber).toList(growable: false);
    state = state.copyWith(
      holdOrders: held,
      cartItems: [...selected.items],
      paidAmount: state.selectedPaymentMethod == PosPaymentMethod.cash ? state.paidAmount : selected.subtotal.toDouble(),
      clearCheckoutResult: true,
    );
  }

  void clearCart() {
    state = state.copyWith(cartItems: const [], paidAmount: 0, clearCheckoutResult: true);
  }

  Future<bool> checkout({int? paidAmount}) async {
    if (state.cartItems.isEmpty) {
      state = state.copyWith(errorMessage: 'Keranjang masih kosong.');
      return false;
    }

    if (state.cartItems.any((item) => item.product.id.trim().isEmpty)) {
      state = state.copyWith(errorMessage: 'Produk tidak valid.');
      return false;
    }

    final amountPaid = paidAmount ??
        (state.selectedPaymentMethod == PosPaymentMethod.cash
            ? state.effectivePaidAmount
            : state.total);
    if (amountPaid < state.total) {
      state = state.copyWith(errorMessage: 'Nominal bayar kurang dari total.');
      return false;
    }

    final itemsSnapshot = [...state.cartItems];
    final discountSnapshot = state.discount;
    final methodSnapshot = state.selectedPaymentMethod;

    state = state.copyWith(
      isSubmitting: true,
      paidAmount: amountPaid.toDouble(),
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      // TODO: Backend transactions API needs tax_rate/tax_amount support.
      final transaction = await _transactionRepository.createTransaction(
        items: itemsSnapshot,
        paidAmount: amountPaid,
        paymentMethod: methodSnapshot.apiValue,
        customerId: int.tryParse(state.selectedCustomer?.id ?? ''),
        discount: discountSnapshot,
      );
      final transactionId = int.tryParse(transaction.id);
      if (transactionId == null || transactionId <= 0) {
        throw const FormatException('ID transaksi untuk struk tidak valid.');
      }
      final receiptPayload = await _receiptRepository.getTransactionReceipt(transactionId);
      final receiptTransaction = receiptPayload.transaction;

      state = state.copyWith(
        isSubmitting: false,
        checkoutResult: PosCheckoutResult(
          invoice: receiptTransaction.invoiceNumber.isEmpty ? 'AUTO' : receiptTransaction.invoiceNumber,
          subtotal: receiptTransaction.subtotal,
          discount: receiptTransaction.discount,
          taxPercent: receiptTransaction.taxRate,
          taxAmount: receiptTransaction.taxAmount,
          total: receiptTransaction.total,
          paidAmount: receiptTransaction.paidAmount,
          change: receiptTransaction.changeAmount,
          paymentMethod: methodSnapshot,
          items: itemsSnapshot,
          createdAt: receiptTransaction.createdAt,
          raw: const <String, dynamic>{},
        ),
        lastPaidTransaction: receiptTransaction,
        lastReceiptPayload: receiptPayload,
        cartItems: const [],
        paidAmount: 0,
        discountAmount: 0,
        taxPercent: 0,
        successMessage: 'Transaksi berhasil.',
      );
      await loadProducts();
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _friendlyCheckoutError(error),
      );
      return false;
    }
  }


  String _friendlyCheckoutError(Object error) {
    if (error is ApiException) {
      final validationMessages = error.errors.values.expand((messages) => messages).where((message) => message.trim().isNotEmpty).toList();
      if (validationMessages.isNotEmpty) return validationMessages.join('\n');
      return error.message;
    }
    if (error is DioException) {
      final exception = ApiException.fromDio(error);
      final validationMessages = exception.errors.values.expand((messages) => messages).where((message) => message.trim().isNotEmpty).toList();
      if (validationMessages.isNotEmpty) return validationMessages.join('\n');
      return exception.message;
    }
    if (error is FormatException) {
      return error.message;
    }
    return 'Checkout gagal. Silakan coba lagi.';
  }

  String _formatHoldNumber(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return 'HOLD-${value.year}${two(value.month)}${two(value.day)}-${two(value.hour)}${two(value.minute)}${two(value.second)}';
  }
}
