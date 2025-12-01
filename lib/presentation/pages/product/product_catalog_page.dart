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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
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
            'rating': product.rating,
          },
        );
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

  @override
  Widget build(BuildContext context) {
    final name = product['nama'] ?? product['name'] ?? 'Product';
    final price = product['harga']?.toString() ?? '0';
    final imageUrl =
        product['image_url'] ?? product['image'] ?? product['gambar'];

    final finalImageUrl = imageUrl != null && !imageUrl.startsWith('http')
        ? 'https://kugar.e-pinggirpapas-sumenep.com/storage/$imageUrl'
        : imageUrl;

    print(
      'DEBUG _ProductCard: product id=${product['id']}, raw imageUrl=$imageUrl, final url=$finalImageUrl',
    );
    final rating = product['rating']?.toDouble();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          final productId = product['id'] as int;
          context.go('${AppRouter.productDetail}/$productId');
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  child: finalImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: finalImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_outlined,
                            color: Colors.grey,
                            size: 48,
                          ),
                        ),
                ),
              ),
            ),
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
                    if (rating != null) ...[
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
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
