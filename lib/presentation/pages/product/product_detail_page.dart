import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/api_provider.dart';
import '../../../domain/entities/product.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/shimmer_widget.dart';
import '../../../shared/themes/app_theme.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProductDetail();
    });
  }

  Future<void> _loadProductDetail() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Validasi productId
      if (widget.productId <= 0) {
        throw Exception('ID produk tidak valid');
      }
      
      final response = await apiService.getProductDetail(widget.productId);
      
      if (!mounted) return;
      
      if (response['success'] == true && response['data'] != null) {
        final productData = Map<String, dynamic>.from(response['data']);
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
        final errorMessage = response['message'] ?? 'Gagal memuat detail produk';
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading product detail:');
      debugPrint(e.toString());
      debugPrint('Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
        
        // Tampilkan snackbar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${_error ?? "Terjadi kesalahan"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addToCart() async {
    if (_product == null) return;
    
    try {
      final authState = ref.read(authProvider);
      if (!authState.isAuthenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Silakan login terlebih dahulu')),
          );
        }
        return;
      }

      final price = _product!['harga'] is double 
          ? _product!['harga'] 
          : double.tryParse(_product!['harga']?.toString() ?? '0') ?? 0.0;

      final success = await ref.read(cartProvider.notifier).addToCart(
        productId: _product!['id'],
        productName: _product!['name'] ?? _product!['nama'],
        price: price,
        quantity: _quantity,
        imageUrl: _product!['image_url'] ?? _product!['image'] ?? _product!['gambar'],
      );
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil ditambahkan ke keranjang')),
          );
        } else {
          final cartState = ref.read(cartProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(cartState.error ?? 'Gagal menambahkan ke keranjang')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }



  // Method untuk menampilkan gambar produk
  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Tampilkan loading indicator jika sedang memuat data
    if (_isLoading) {
      return const Scaffold(
        appBar: null,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Tampilkan pesan error jika ada error
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat detail produk',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadProductDetail,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // Tampilkan pesan jika produk tidak ditemukan
    if (_product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Produk tidak ditemukan',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Produk yang Anda cari tidak ditemukan atau telah dihapus',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      );
    }

    // Deklarasi variabel product, price, dan formattedPrice
    final product = _product!;
    final price = product['harga'] is double 
        ? product['harga'] 
        : double.tryParse(product['harga']?.toString() ?? '0') ?? 0.0;
        
    final formattedPrice = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(price);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProductImage(product['image_url'] ?? ''),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => context.pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama dan Harga
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['nama'] ?? 'Nama Produk',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formattedPrice,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tombol favorit
                      IconButton(
                        icon: const Icon(Icons.favorite_border, size: 28),
                        onPressed: () {
                          // TODO: Add to favorites
                        },
                      ),
                    ],
                  ),
                  
                  // Kuantitas
                  const SizedBox(height: 16),
                  _buildQuantitySelector(),
                  
                  // Deskripsi
                  const SizedBox(height: 24),
                  _buildSectionTitle('Deskripsi'),
                  const SizedBox(height: 8),
                  Text(
                    product['deskripsi'] ?? 'Tidak ada deskripsi',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),
                  
                  // Informasi Penjual
                  const SizedBox(height: 24),
                  _buildSectionTitle('Informasi Penjual'),
                  const SizedBox(height: 12),
                  _buildSellerInfo(context, product),
                  
                  // Spacer untuk bottom navigation
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, product, price),
    );
  }
  
  
  
  Widget _buildSellerInfo(BuildContext context, Map<String, dynamic> product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text(
                'Penjual',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: product['alamat'] != null 
                  ? Text(product['alamat'].toString())
                  : null,
              trailing: ElevatedButton.icon(
                onPressed: product['nomor_hp'] != null 
                    ? () => _launchPhoneCall(product['nomor_hp'].toString())
                    : null,
                icon: const Icon(Icons.phone, size: 16),
                label: const Text('Hubungi'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            if (product['nomor_hp'] != null) ...[
              const Divider(height: 24),
              _buildContactInfo(
                icon: Icons.phone,
                title: 'Telepon',
                value: product['nomor_hp'].toString(),
                onTap: () => _launchPhoneCall(product['nomor_hp'].toString()),
              ),
            ],
            if (product['alamat'] != null) ...[
              const SizedBox(height: 8),
              _buildContactInfo(
                icon: Icons.location_on,
                title: 'Alamat',
                value: product['alamat'].toString(),
                onTap: () {
                  // TODO: Buka peta
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
      onTap: onTap,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 20),
            onPressed: _quantity > 1 ? () {
              setState(() => _quantity--);
            } : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$_quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: () {
              setState(() => _quantity++);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
  
  Future<void> _launchPhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    try {
      if (await url_launcher.canLaunchUrl(Uri.parse(url))) {
        await url_launcher.launchUrl(Uri.parse(url));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka aplikasi telepon')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan saat membuka aplikasi telepon')),
        );
      }
    }
  }

  Widget _buildBottomBar(BuildContext context, Map<String, dynamic> product, double price) {
    final isLoggedIn = ref.read(authProvider).isAuthenticated;
    final totalPrice = price * _quantity;
    final formattedTotalPrice = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(totalPrice);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Harga',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedTotalPrice,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isLoggedIn
                    ? () {
                        _addToCart();
                      }
                    : () {
                        context.push('/login');
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isLoggedIn ? 'Beli Sekarang' : 'Login Dulu',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
