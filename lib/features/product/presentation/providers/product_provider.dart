import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/product/data/models/product_model.dart';
import 'package:profesionalservis_mobile/features/product/data/repositories/product_repository.dart';

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final notifier = ProductNotifier(ref.watch(productRepositoryProvider));
  notifier.fetchInitial();
  ref.onDispose(notifier.dispose);
  return notifier;
});

class ProductState {
  const ProductState({
    this.items = const [],
    this.categories = const [],
    this.searchQuery = '',
    this.selectedCategory,
    this.isLoading = false,
    this.isSubmitting = false,
    this.hasNextPage = false,
    this.currentPage = 1,
    this.errorMessage,
  });

  final List<ProductModel> items;
  final List<String> categories;
  final String searchQuery;
  final String? selectedCategory;
  final bool isLoading;
  final bool isSubmitting;
  final bool hasNextPage;
  final int currentPage;
  final String? errorMessage;

  ProductState copyWith({
    List<ProductModel>? items,
    List<String>? categories,
    String? searchQuery,
    String? selectedCategory,
    bool clearSelectedCategory = false,
    bool? isLoading,
    bool? isSubmitting,
    bool? hasNextPage,
    int? currentPage,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProductState(
      items: items ?? this.items,
      categories: categories ?? this.categories,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  ProductNotifier(this._repository) : super(const ProductState());

  final ProductRepository _repository;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchInitial() async {
    await _fetch(page: 1, resetData: true);
  }

  Future<void> refresh() async {
    await _fetch(page: 1, resetData: true);
  }

  Future<void> fetchMore() async {
    if (state.isLoading || !state.hasNextPage) {
      return;
    }

    await _fetch(page: state.currentPage + 1, resetData: false);
  }

  Future<void> _fetch({required int page, required bool resetData}) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final response = await _repository.getProducts(
        page: page,
        search: state.searchQuery,
        category: state.selectedCategory,
      );

      final nextItems = resetData
          ? response.data
          : [...state.items, ...response.data];

      state = state.copyWith(
        items: nextItems,
        categories: _extractCategories(nextItems),
        isLoading: false,
        hasNextPage: response.hasNextPage,
        currentPage: response.currentPage ?? page,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat produk. Silakan coba lagi.',
      );
    }
  }

  void setSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), fetchInitial);
  }

  Future<void> setCategory(String? category) async {
    state = state.copyWith(
      selectedCategory: category,
      clearSelectedCategory: category == null || category.isEmpty,
    );
    await fetchInitial();
  }

  Future<bool> addProduct(ProductModel product) async {
    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);
    try {
      await _repository.addProduct(product);
      state = state.copyWith(isSubmitting: false);
      await fetchInitial();
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal menambahkan produk.',
      );
      return false;
    }
  }

  Future<bool> updateProduct({required String id, required ProductModel product}) async {
    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);
    try {
      await _repository.editProduct(id: id, product: product);
      state = state.copyWith(isSubmitting: false);
      await fetchInitial();
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal mengubah produk.',
      );
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);
    try {
      await _repository.deleteProduct(id);
      state = state.copyWith(isSubmitting: false);
      await fetchInitial();
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal menghapus produk.',
      );
      return false;
    }
  }

  List<String> _extractCategories(List<ProductModel> items) {
    final categories = items
        .map((product) => product.category)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return categories;
  }
}
