import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/category.dart';
import 'api_provider.dart';

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
    print('DEBUG: loadProducts called - refresh: $refresh, category: $category, search: $search');
    
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
      print('DEBUG: Calling API getProducts...');
      final response = await _apiService.getProducts(
        page: state.currentPage,
        category: category,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      
      print('DEBUG: API response: $response');

      if (response != null && response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>?;
        final productsData = (data != null && data['data'] is List) 
            ? data['data'] as List<dynamic> 
            : <dynamic>[];
        
        print('DEBUG: Products data length: ${productsData.length}');
        
        if (productsData != null) {
          final newProducts = productsData.map((product) {
            try {
              if (product is Map<String, dynamic>) {
                return Product.fromJson(product);
              }
              return null;
            } catch (e) {
              print('Error parsing product: $e');
              return null;
            }
          }).whereType<Product>().toList();

          print('DEBUG: Parsed products count: ${newProducts.length}');

          state = state.copyWith(
            products: [...state.products, ...newProducts],
            isLoading: false,
            isLoadingMore: false,
            hasMore: (data?['next_page_url'] != null) ?? false,
            currentPage: state.currentPage + 1,
          );
        } else {
          print('DEBUG: No products data found in response');
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            error: 'No products data found',
          );
        }
      } else {
        print('DEBUG: API response not successful: ${response['message']}');
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: response['message'] ?? 'Failed to load products',
        );
      }
    } catch (e) {
      print('DEBUG: Exception in loadProducts: $e');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString().contains('SocketException') 
            ? 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.'
            : 'Gagal memuat produk. Silakan coba lagi nanti.',
      );
      print('Error loading products: $e');
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
      print('DEBUG: Calling API getCategories...');
      final response = await _apiService.getCategories();
      print('DEBUG: Categories API response: $response');

      if (response['success'] == true && response['data'] != null) {
        final categoriesData = response['data'] as List<dynamic>;
        print('DEBUG: Categories data length: ${categoriesData.length}');
        
        final categories = categoriesData.map((c) {
          try {
            final category = Category.fromJson(c as Map<String, dynamic>);
            print('DEBUG: Parsed category: ${category.name}');
            return category;
          } catch (e) {
            print('DEBUG: Error parsing category: $e, data: $c');
            // Create fallback category
            return Category(
              id: (c['id'] as int?) ?? 0,
              name: c['name'] ?? c['nama'] ?? 'Unknown Category',
              description: c['description'] ?? c['deskripsi'] ?? '',
              imageUrl: c['image_url'] ?? c['image'] ?? c['gambar'] as String?,
              productCount: c['product_count'] as int? ?? 0,
            );
          }
        }).toList();

        print('DEBUG: Final categories count: ${categories.length}');
        state = state.copyWith(categories: categories);
      } else {
        print('DEBUG: Categories API response not successful: ${response['message']}');
      }
    } catch (e) {
      print('DEBUG: Exception in loadCategories: $e');
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
