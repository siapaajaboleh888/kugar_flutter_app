import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/category.dart';

// Provider for API service
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Product state
class ProductState {
  final List<Product> products;
  final List<Product> featuredProducts;
  final List<Category> categories;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final Map<int, Product> productDetails;

  ProductState({
    this.products = const [],
    this.featuredProducts = const [],
    this.categories = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.productDetails = const {},
  });

  ProductState copyWith({
    List<Product>? products,
    List<Product>? featuredProducts,
    List<Category>? categories,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    int? currentPage,
    Map<int, Product>? productDetails,
  }) {
    return ProductState(
      products: products ?? this.products,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      productDetails: productDetails ?? this.productDetails,
    );
  }
}

// Product provider
class ProductProvider extends StateNotifier<ProductState> {
  final ApiService _apiService;

  ProductProvider(this._apiService) : super(ProductState());

  Future<void> loadProducts({
    bool refresh = false,
    String? category,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    if (refresh) {
      state = state.copyWith(
        currentPage: 1,
        products: [],
        hasMore: true,
        error: null,
      );
    }

    if (state.isLoading || (!refresh && state.isLoadingMore)) return;

    state = state.copyWith(isLoading: !refresh, isLoadingMore: refresh, error: null);

    try {
      final response = await _apiService.getProducts(
        page: state.currentPage,
        category: category,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final productsData = data['data'] as List<dynamic>;
        final newProducts = productsData.map((p) => Product.fromJson(p as Map<String, dynamic>)).toList();

        state = state.copyWith(
          products: refresh ? newProducts : [...state.products, ...newProducts],
          isLoading: false,
          isLoadingMore: false,
          currentPage: state.currentPage + 1,
          hasMore: newProducts.length >= 10,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadFeaturedProducts() async {
    try {
      final response = await _apiService.getFeaturedProducts();

      if (response['success'] == true && response['data'] != null) {
        final productsData = response['data'] as List<dynamic>;
        final featuredProducts = productsData.map((p) => Product.fromJson(p as Map<String, dynamic>)).toList();

        state = state.copyWith(featuredProducts: featuredProducts);
      }
    } catch (e) {
      // Handle error silently for featured products
    }
  }

  Future<void> loadCategories() async {
    try {
      final response = await _apiService.getCategories();

      if (response['success'] == true && response['data'] != null) {
        final categoriesData = response['data'] as List<dynamic>;
        final categories = categoriesData.map((c) => Category.fromJson(c as Map<String, dynamic>)).toList();

        state = state.copyWith(categories: categories);
      }
    } catch (e) {
      // Handle error silently for categories
    }
  }

  Future<Product?> getProductDetail(int productId) async {
    // Check if already loaded
    if (state.productDetails.containsKey(productId)) {
      return state.productDetails[productId];
    }

    try {
      final response = await _apiService.getProductDetail(productId);

      if (response['success'] == true && response['data'] != null) {
        final product = Product.fromJson(response['data'] as Map<String, dynamic>);
        
        final updatedDetails = Map<int, Product>.from(state.productDetails);
        updatedDetails[productId] = product;
        
        state = state.copyWith(productDetails: updatedDetails);
        return product;
      }
    } catch (e) {
      // Error handled by caller
    }

    return null;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = ProductState();
  }
}

// Product provider instance
final productProvider = StateNotifierProvider<ProductProvider, ProductState>((ref) {
  return ProductProvider(ref.read(apiServiceProvider));
});

// Featured products provider
final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final productProviderNotifier = ref.read(productProvider.notifier);
  await productProviderNotifier.loadFeaturedProducts();
  return ref.read(productProvider).featuredProducts;
});

// Product by category provider
final productsByCategoryProvider = FutureProvider.family<List<Product>, int>((ref, categoryId) async {
  final productProviderNotifier = ref.read(productProvider.notifier);
  await productProviderNotifier.loadProducts(category: categoryId.toString());
  return ref.read(productProvider).products;
});

// Product search provider
final productSearchProvider = FutureProvider.family<List<Product>, String>((ref, query) async {
  final productProviderNotifier = ref.read(productProvider.notifier);
  await productProviderNotifier.loadProducts(search: query);
  return ref.read(productProvider).products;
});

// Product detail provider
final productDetailProvider = FutureProvider.family<Product?, int>((ref, productId) async {
  final productProviderNotifier = ref.read(productProvider.notifier);
  return await productProviderNotifier.getProductDetail(productId);
});

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final productProviderNotifier = ref.read(productProvider.notifier);
  await productProviderNotifier.loadCategories();
  return ref.read(productProvider).categories;
});

// Search provider
final searchProvider = StateNotifierProvider<SearchProvider, SearchState>((ref) {
  return SearchProvider(ref.watch(apiServiceProvider));
});

class SearchState {
  final List<Product> results;
  final bool isLoading;
  final String? error;
  final String query;

  SearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
  });

  SearchState copyWith({
    List<Product>? results,
    bool? isLoading,
    String? error,
    String? query,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      query: query ?? this.query,
    );
  }
}

class SearchProvider extends StateNotifier<SearchState> {
  final ApiService _apiService;

  SearchProvider(this._apiService) : super(SearchState());

  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(results: [], query: '');
      return;
    }

    state = state.copyWith(isLoading: true, error: null, query: query);

    try {
      final response = await _apiService.getProducts(search: query);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final productsData = data['data'] as List<dynamic>;
        final results = productsData.map((p) => Product.fromJson(p as Map<String, dynamic>)).toList();

        state = state.copyWith(
          results: results,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        results: [],
      );
    }
  }

  void clearSearch() {
    state = SearchState();
  }
}
