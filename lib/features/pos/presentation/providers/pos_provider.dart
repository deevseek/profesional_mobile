import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/pos/data/models/pos_cart_item.dart';
import 'package:profesionalservis_mobile/features/pos/data/repositories/transaction_repository.dart';
import 'package:profesionalservis_mobile/features/product/data/models/product_model.dart';
import 'package:profesionalservis_mobile/features/product/data/repositories/product_repository.dart';

final posProvider = StateNotifierProvider<PosNotifier, PosState>((ref) {
  final notifier = PosNotifier(
    productRepository: ref.watch(productRepositoryProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
  );
  notifier.loadProducts();
  ref.onDispose(notifier.dispose);
  return notifier;
});

class PosCheckoutResult {
  const PosCheckoutResult({
    required this.invoice,
    required this.subtotal,
    required this.total,
    required this.change,
  });

  final String invoice;
  final int subtotal;
  final int total;
  final int change;
}

class PosState {
  const PosState({
    this.products = const [],
    this.filteredProducts = const [],
    this.cartItems = const [],
    this.heldCarts = const {},
    this.search = '',
    this.taxPercent = 11,
    this.isLoadingProducts = false,
    this.isSubmittingCheckout = false,
    this.errorMessage,
    this.checkoutResult,
  });

  final List<ProductModel> products;
  final List<ProductModel> filteredProducts;
  final List<PosCartItem> cartItems;
  final Map<String, List<PosCartItem>> heldCarts;
  final String search;
  final int taxPercent;
  final bool isLoadingProducts;
  final bool isSubmittingCheckout;
  final String? errorMessage;
  final PosCheckoutResult? checkoutResult;

  int get subtotal => cartItems.fold<int>(0, (sum, item) => sum + item.lineTotal);
  int get taxAmount => ((subtotal * taxPercent) / 100).round();
  int get total => subtotal + taxAmount;

  PosState copyWith({
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
    List<PosCartItem>? cartItems,
    Map<String, List<PosCartItem>>? heldCarts,
    String? search,
    int? taxPercent,
    bool? isLoadingProducts,
    bool? isSubmittingCheckout,
    String? errorMessage,
    bool clearErrorMessage = false,
    PosCheckoutResult? checkoutResult,
    bool clearCheckoutResult = false,
  }) {
    return PosState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      cartItems: cartItems ?? this.cartItems,
      heldCarts: heldCarts ?? this.heldCarts,
      search: search ?? this.search,
      taxPercent: taxPercent ?? this.taxPercent,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      isSubmittingCheckout: isSubmittingCheckout ?? this.isSubmittingCheckout,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      checkoutResult: clearCheckoutResult ? null : (checkoutResult ?? this.checkoutResult),
    );
  }
}

class PosNotifier extends StateNotifier<PosState> {
  PosNotifier({
    required ProductRepository productRepository,
    required TransactionRepository transactionRepository,
  }) : _productRepository = productRepository,
       _transactionRepository = transactionRepository,
       super(const PosState());

  final ProductRepository _productRepository;
  final TransactionRepository _transactionRepository;
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
      state = state.copyWith(
        products: response.data,
        filteredProducts: response.data,
        isLoadingProducts: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingProducts: false,
        errorMessage: 'Gagal memuat produk POS.',
      );
    }
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
        clearCheckoutResult: true,
      );
      return;
    }

    final current = state.cartItems[index];
    final updated = [...state.cartItems]
      ..[index] = current.copyWith(quantity: current.quantity + 1);
    state = state.copyWith(cartItems: updated, clearCheckoutResult: true);
  }

  void updateQuantity({required String productId, required int quantity}) {
    final safeQty = quantity < 1 ? 1 : quantity;
    final updated = state.cartItems
        .map((item) => item.product.id == productId ? item.copyWith(quantity: safeQty) : item)
        .toList(growable: false);
    state = state.copyWith(cartItems: updated, clearCheckoutResult: true);
  }

  void updateDiscount({required String productId, required int discount}) {
    final updated = state.cartItems
        .map((item) {
          if (item.product.id != productId) {
            return item;
          }
          final maxDiscount = item.lineBaseTotal;
          final safeDiscount = discount.clamp(0, maxDiscount);
          return item.copyWith(discount: safeDiscount);
        })
        .toList(growable: false);
    state = state.copyWith(cartItems: updated, clearCheckoutResult: true);
  }

  void removeItem(String productId) {
    state = state.copyWith(
      cartItems: state.cartItems.where((item) => item.product.id != productId).toList(growable: false),
      clearCheckoutResult: true,
    );
  }

  void setTaxPercent(int value) {
    state = state.copyWith(
      taxPercent: value.clamp(0, 100),
      clearCheckoutResult: true,
    );
  }

  void holdCart() {
    if (state.cartItems.isEmpty) {
      return;
    }
    final holdId = 'HOLD-${DateTime.now().millisecondsSinceEpoch}';
    final held = {...state.heldCarts, holdId: [...state.cartItems]};
    state = state.copyWith(
      heldCarts: held,
      cartItems: const [],
      clearCheckoutResult: true,
    );
  }

  void resumeCart(String holdId) {
    final selected = state.heldCarts[holdId];
    if (selected == null) {
      return;
    }
    final held = {...state.heldCarts}..remove(holdId);
    state = state.copyWith(
      heldCarts: held,
      cartItems: [...selected],
      clearCheckoutResult: true,
    );
  }

  void clearCart() {
    state = state.copyWith(cartItems: const [], clearCheckoutResult: true);
  }

  Future<bool> checkout({required int paidAmount}) async {
    if (state.cartItems.isEmpty) {
      state = state.copyWith(errorMessage: 'Keranjang masih kosong.');
      return false;
    }

    state = state.copyWith(isSubmittingCheckout: true, clearErrorMessage: true);
    try {
      final result = await _transactionRepository.createTransaction(
        items: state.cartItems,
        taxPercent: state.taxPercent,
        paidAmount: paidAmount,
      );

      state = state.copyWith(
        isSubmittingCheckout: false,
        checkoutResult: PosCheckoutResult(
          invoice: result.invoice,
          subtotal: result.subtotal,
          total: result.total,
          change: result.change,
        ),
        cartItems: const [],
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmittingCheckout: false,
        errorMessage: 'Checkout gagal. Silakan coba lagi.',
      );
      return false;
    }
  }
}
