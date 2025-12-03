import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/product_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/product.dart';

class ProductCatalogPage extends ConsumerStatefulWidget {
  const ProductCatalogPage({super.key});

  @override
  ConsumerState<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends ConsumerState<ProductCatalogPage> {
  @override
  void initState() {
    super.initState();
    // Load products and categories when page opens
    Future.microtask(() {
      ref.read(productProvider.notifier).loadProducts();
      ref.read(productProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final products = productState.products;
    final categories = productState.categories;
    final isLoading = productState.isLoading;
    final error = productState.error;
    
    // Debug log
    debugPrint('Product catalog build - Loading: $isLoading, Products: ${products.length}, Error: $error');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('home'),
          tooltip: 'Kembali ke Beranda',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ProductSearchDelegate());
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategories(context, categories),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(productProvider.notifier)
                    .loadProducts(refresh: true);
              },
              child: isLoading && products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : error != null && products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text('Error: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(productProvider.notifier)
                                  .loadProducts(refresh: true);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : products.isEmpty
                  ? const Center(child: Text('No products found'))
                  : _buildProductGrid(context, products),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context, List<dynamic> categories) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: 'All',
              isSelected: false,
              onTap: () async {
                ref.read(productProvider.notifier).loadProducts(refresh: true);
              },
            );
          }
          final category = categories[index - 1];
          return _CategoryChip(
            label: category.name ?? 'Category',
            isSelected: false,
            onTap: () async {
              ref
                  .read(productProvider.notifier)
                  .loadProducts(
                    refresh: true,
                    category: category.id.toString(),
                  );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, List<dynamic> products) {
    if (products.isEmpty) {
      return const Center(
        child: Text('Tidak ada produk yang tersedia'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        try {
          if (products[index] is! Product) return const SizedBox.shrink();
          
          final product = products[index] as Product;
          return _ProductCard(
            product: {
              'id': product.id,
              'nama': product.name,
              'name': product.name,
              'harga': product.price,
              'price': product.price,
              'deskripsi': product.description,
              'description': product.description,
              'image_url': product.imageUrl,
              'image': product.imageUrl,
              'gambar': product.imageUrl,
              'rating': product.rating ?? 0.0,
            },
          );
        } catch (e) {
          debugPrint('Error building product card: $e');
          return const SizedBox.shrink();
        }
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Products'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [const Text('Filter options coming soon...')],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  String? _getImageUrl() {
    try {
      debugPrint('\n=== IMAGE URL DEBUG START ===');
      debugPrint('Product ID: ${product['id']}');
      debugPrint('Available fields: ${product.keys}');
      
      // Cari URL gambar dari field yang mungkin
      String? imageUrl;
      
      // Cek field yang mungkin berisi URL gambar
      final possibleFields = [
        'image_url', 'imageUrl', 'image',
        'foto', 'photo',
        'gambar', 'image_path', 'url_gambar'
      ];
      
      for (var field in possibleFields) {
        if (product[field] != null && product[field].toString().isNotEmpty) {
          imageUrl = product[field].toString().trim();
          debugPrint('Found image URL in field "$field": $imageUrl');
          
          // Bersihkan URL dari karakter yang tidak diinginkan
          imageUrl = imageUrl.replaceAll('\\/', '/');
          
          // Pastikan URL memiliki protokol
          if (!imageUrl.startsWith('http')) {
            imageUrl = 'http://$imageUrl';
          }
          
          debugPrint('Processed URL: $imageUrl');
          break;
        }
      }

      // Jika tidak ditemukan URL gambar
      if (imageUrl == null || imageUrl.isEmpty) {
        debugPrint('No image URL found for product ${product['id']}');
        return null;
      }

      // Clean up URL
      debugPrint('\n--- URL Processing ---');
      debugPrint('Before cleanup: $imageUrl');
      
      imageUrl = imageUrl.trim();
      debugPrint('After trim: $imageUrl');
      
      // Handle escaped backslashes
      if (imageUrl.contains(r'\/')) {
        debugPrint('Found escaped backslashes, replacing...');
        imageUrl = imageUrl.replaceAll(r'\/', '/');
        debugPrint('After replacing backslashes: $imageUrl');
      }
      
      // For Chrome, use wisatalembung.test directly instead of 10.0.2.2
      if (imageUrl.contains('wisatalembung.test')) {
        debugPrint('Using wisatalembung.test domain: $imageUrl');
      }
      
      // Cek URL final
      debugPrint('\n--- Final URL Check ---');
      debugPrint('Is absolute URL: ${imageUrl.startsWith(RegExp(r'https?://'))}');
      debugPrint('URL length: ${imageUrl.length}');
      debugPrint('Final URL: $imageUrl');
      
      // Jika URL sudah lengkap
      if (imageUrl.startsWith(RegExp(r'https?://'))) {
        debugPrint('Using full URL: $imageUrl');
        debugPrint('=== IMAGE URL DEBUG END ===\n');
        return imageUrl;
      }

      // Handle relative paths - use wisatalembung.test for Chrome
      final baseUrl = 'http://wisatalembung.test';
      
      // Jika URL relatif dengan storage/
      if (imageUrl.startsWith('storage/') || imageUrl.startsWith('/storage/')) {
        final url = '$baseUrl/${imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl}';
        debugPrint('Converted storage path to URL: $url');
        return url;
      }

      // Jika URL relatif tanpa prefix
      if (!imageUrl.startsWith('http')) {
        // Hapus leading slash jika ada
        if (imageUrl.startsWith('/')) {
          imageUrl = imageUrl.substring(1);
        }
        final url = '$baseUrl/storage/$imageUrl';
        debugPrint('Converted relative path to URL: $url');
        return url;
      }

      return imageUrl;
    } catch (e, stackTrace) {
      debugPrint('Error getting image URL: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = product['nama'] ?? product['name'] ?? 'Product';
    final price = product['harga']?.toString() ?? '0';
    final imageUrl = _getImageUrl();
    
    // Debug log
    debugPrint('Product ID: ${product['id']} - Image URL: $imageUrl');
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          try {
            final productId = product['id']?.toString();
            if (productId == null) {
              throw Exception('Product ID is null');
            }
            debugPrint('Navigating to product detail with ID: $productId');
            context.goNamed(
              'productDetail',
              pathParameters: {'id': productId},
            );
          } catch (e, stackTrace) {
            debugPrint('Error navigating to product detail: $e');
            debugPrint('Stack trace: $stackTrace');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: Gagal membuka detail produk')),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: _buildImageWidget(imageUrl),
                ),
              ),
            ),
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      'Rp $price',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImageWidget(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildErrorWidget('Tidak ada gambar');
    }

    // Debug log
    debugPrint('Trying to load image: $imageUrl');

    // Gunakan Image.network dengan error handling yang lebih baik
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return frame == null 
            ? _buildLoadingWidget()
            : child;
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingWidget();
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Image load error: $error');
        debugPrint('Stack trace: $stackTrace');
        return _buildErrorWidget('Gagal memuat gambar');
      },
      headers: const {
        'Accept': 'image/*',
        'Access-Control-Allow-Origin': '*',
      },
    );
  }
  
  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
  
  Widget _buildErrorWidget(String message) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image_outlined,
            color: Colors.grey,
            size: 36,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: Implement search results
    return const Center(child: Text('Search results coming soon...'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: Implement search suggestions
    return const Center(child: Text('Start typing to search...'));
  }
}
