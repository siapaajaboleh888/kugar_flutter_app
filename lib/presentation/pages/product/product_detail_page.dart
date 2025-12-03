import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
      debugPrint('Mengambil detail produk ID: ${widget.productId}');
      
      final response = await apiService.getProductDetail(widget.productId);
      debugPrint('Respons API: ${response.toString()}');

      if (!mounted) return;
      
      if (response['success'] == true && response['data'] != null) {
        final productData = response['data'] as Map<String, dynamic>;
        debugPrint('Data produk: $productData');
        
        setState(() {
          _product = {
            'id': productData['id'],
            'nama': productData['nama'] ?? productData['title'] ?? 'Produk',
            'harga': double.tryParse((productData['harga'] ?? productData['price'] ?? '0').toString()) ?? 0.0,
            'deskripsi': productData['deskripsi'] ?? productData['text'] ?? '',
            'image_url': productData['image_url'] ?? productData['foto'] ?? productData['image'],
            'satuan': productData['satuan'] ?? 'pcs',
            'nomor_hp': productData['nomor_hp'] ?? '',
            'alamat': productData['alamat'] ?? '',
            'is_available': true,
          };
          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Gagal memuat detail produk');
      }
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
        
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Selalu arahkan ke halaman daftar produk
            context.go('/products');
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProductDetail,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _product != null
                  ? _buildProductDetail()
                  : const Center(child: Text('Produk tidak ditemukan')),
      bottomNavigationBar: _product != null
          ? _buildBottomBar(
              context, 
              _product!, 
              double.tryParse(_product!['harga']?.toString() ?? '0') ?? 0
            )
          : null,
    );
  }

  Widget _buildProductDetail() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk
          _buildProductImage(_product!['image_url']),
          const SizedBox(height: 16),
          
          // Nama dan Harga
          Text(
            _product!['nama'] ?? 'Produk',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${NumberFormat('#,##0', 'id_ID').format(_product!['harga'] is double ? _product!['harga'] : double.tryParse(_product!['harga']?.toString() ?? '0') ?? 0)} / ${_product!['satuan']}',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Deskripsi
          const SizedBox(height: 16),
          _buildSectionTitle('Deskripsi'),
          const SizedBox(height: 8),
          Text(
            _product!['deskripsi'] ?? 'Tidak ada deskripsi',
            style: const TextStyle(fontSize: 16),
          ),
          
          // Info Penjual
          const SizedBox(height: 24),
          _buildSellerInfo(context, _product!),
        ],
      ),
    );
  }

  Widget _buildSellerInfo(BuildContext context, Map<String, dynamic> product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Penjual',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactInfo(
              icon: Icons.location_on,
              title: 'Alamat',
              value: product['alamat'] ?? 'Alamat tidak tersedia',
            ),
            const SizedBox(height: 8),
            _buildContactInfo(
              icon: Icons.phone,
              title: 'Telepon',
              value: product['nomor_hp'] ?? 'Nomor tidak tersedia',
              onTap: product['nomor_hp'] != null
                  ? () => _launchPhoneCall(product['nomor_hp'])
                  : null,
            ),
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat melakukan panggilan telepon'),
            backgroundColor: Colors.red,
          ),
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
