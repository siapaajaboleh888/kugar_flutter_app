import 'package:flutter/material.dart';

import 'api_service.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final Map<String, dynamic> product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ApiService _api = ApiService();
  bool _loading = false;
  Map<String, dynamic>? _detail;
  String? _error;

  int get _id => widget.product['id'] as int;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.getProdukDetail(_id);
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _detail = result['data'] as Map<String, dynamic>;
        });
      } else {
        setState(() {
          _error = 'Gagal memuat detail produk';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.product['nama'] ?? widget.product['name'] ?? 'Produk';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final data = <String, dynamic>{
      ...widget.product,
      if (_detail != null) ..._detail!,
    };
    final harga = data['harga']?.toString() ?? '-';
    final deskripsi = data['deskripsi'] ?? '';
    final imageUrl = data['image_url'] ?? data['image'] ?? data['gambar'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl.startsWith('http') 
                    ? imageUrl 
                    : 'http://wisatalembung.test/storage/$imageUrl',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    color: Colors.grey.shade100,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Text(
            data['nama'] ?? data['name'] ?? 'Produk',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp $harga',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            deskripsi,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
