import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/api_provider.dart';
import '../../../domain/entities/product.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/shimmer_widget.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _product;
  String? _error;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProductDetail();
  }

  Future<void> _loadProductDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getProductDetail(widget.productId);
      
      print('DEBUG: Product detail response: $response');
      
      if (response['success'] == true && response['data'] != null) {
        final productData = response['data'] as Map<String, dynamic>;
        final product = Product.fromJson(productData);
        
        setState(() {
          _product = {
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
            'category': product.category,
            'is_available': product.isAvailable,
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Product not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG: Error loading product detail: $e');
      setState(() {
        _error = 'Error loading product: $e';
        _isLoading = false;
      });
    }
  }

  void _addToCart() async {
    if (_product == null) return;
    
    try {
      final authState = ref.read(authProvider);
      if (!authState.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to add items to cart')),
        );
        return;
      }

      final success = await ref.read(cartProvider.notifier).addToCart(
        productId: _product!['id'],
        productName: _product!['name'] ?? _product!['nama'],
        price: (_product!['price'] ?? _product!['harga']).toDouble(),
        quantity: _quantity,
        imageUrl: _product!['image_url'] ?? _product!['image'] ?? _product!['gambar'],
      );
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to cart!')),
          );
        } else {
          final cartState = ref.read(cartProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(cartState.error ?? 'Failed to add to cart')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding to cart: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Detail')),
        body: _buildShimmer(),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Detail')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error ?? 'An error occurred'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProductDetail,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProductImage(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: Implement wishlist functionality
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(),
                  const SizedBox(height: 24),
                  _buildQuantitySelector(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildReviews(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: [
        ShimmerWidget.rectangular(width: double.infinity, height: 300),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerWidget.rectangular(width: double.infinity * 0.8, height: 24),
              const SizedBox(height: 8),
              ShimmerWidget.rectangular(width: double.infinity * 0.4, height: 20),
              const SizedBox(height: 16),
              ShimmerWidget.rectangular(width: double.infinity, height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage() {
    final imageUrl = _product!['image_url'] ?? _product!['image'] ?? _product!['gambar'];
    
    return Container(
      color: Colors.grey.shade100,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl.startsWith('http')
                  ? imageUrl
                  : 'https://kugar.e-pinggirpapas-sumenep.com/storage/$imageUrl',
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                  size: 64,
                ),
              ),
            )
          : Container(
              color: Colors.grey.shade200,
              child: const Icon(
                Icons.image_outlined,
                color: Colors.grey,
                size: 64,
              ),
            ),
    );
  }

  Widget _buildProductInfo() {
    final name = _product!['nama'] ?? _product!['name'] ?? 'Product';
    final price = _product!['harga']?.toString() ?? '0';
    final rating = _product!['rating']?.toDouble();
    final description = _product!['deskripsi'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Rp $price',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Spacer(),
            if (rating != null) ...[
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(rating.toStringAsFixed(1)),
                ],
              ),
            ],
          ],
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Text(
          'Quantity:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
              ),
              SizedBox(
                width: 40,
                child: Text(
                  _quantity.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => _quantity++),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            onPressed: _addToCart,
            child: const Text('Add to Cart'),
          ),
        ),
        const SizedBox(width: 16),
        CustomButton(
          onPressed: () {
            // TODO: Implement buy now functionality
          },
          isOutlined: true,
          child: const Text('Buy Now'),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    final description = _product!['deskripsi'] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description.isNotEmpty ? description : 'No description available.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Reviews',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // TODO: Navigate to reviews page
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // TODO: Add review widgets
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('No reviews yet. Be the first to review!'),
          ),
        ),
      ],
    );
  }
}
