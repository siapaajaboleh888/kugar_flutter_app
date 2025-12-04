import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/admin_product_model.dart';
import '../../../../data/providers/admin_provider.dart';
import '../../../../data/services/admin_service.dart';

class AdminProductsPage extends ConsumerStatefulWidget {
  const AdminProductsPage({super.key});

  @override
  ConsumerState<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends ConsumerState<AdminProductsPage> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  int _currentPage = 1;
  final int _perPage = 15;
  List<AdminProduct> _products = [];
  bool _isLoading = false;
  String? _error;
  int _totalPages = 1;
  int _totalProducts = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final adminService = ref.read(adminServiceProvider);
      final response = await adminService.getProducts(
        page: _currentPage,
        perPage: _perPage,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        category: _selectedCategory,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final productsList = data is Map
            ? (data['data'] as List? ?? [])
            : (data as List? ?? []);

        setState(() {
          _products = productsList
              .map((e) => AdminProduct.fromJson(e as Map<String, dynamic>))
              .toList();
          _currentPage = data is Map ? (data['current_page'] as int? ?? 1) : 1;
          _totalPages = data is Map ? (data['last_page'] as int? ?? 1) : 1;
          _totalProducts = data is Map ? (data['total'] as int? ?? productsList.length) : productsList.length;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] as String? ?? 'Failed to load products';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(int productId, String productName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus produk "$productName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final adminService = ref.read(adminServiceProvider);
      final response = await adminService.deleteProduct(productId);

      if (response['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil dihapus')),
        );
        _loadProducts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus produk: $e')),
        );
      }
    }
  }

  void _showProductForm({AdminProduct? product}) {
    showDialog(
      context: context,
      builder: (context) => _ProductFormDialog(
        product: product,
        onSaved: _loadProducts,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/dashboard'),
          tooltip: 'Kembali ke Dashboard',
        ),
        title: const Text('Manage Products'),
        actions: [
          if (_totalProducts > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'Total: $_totalProducts',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _currentPage = 1;
                          _loadProducts();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) {
                _currentPage = 1;
                _loadProducts();
              },
            ),
          ),

          // Product List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadProducts,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _products.isEmpty
                        ? const Center(child: Text('Tidak ada produk'))
                        : RefreshIndicator(
                            onRefresh: _loadProducts,
                            child: ListView.builder(
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                final product = _products[index];
                                return _buildProductCard(product);
                              },
                            ),
                          ),
          ),

          // Pagination
          if (_totalPages > 1)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _currentPage > 1
                        ? () {
                            setState(() => _currentPage--);
                            _loadProducts();
                          }
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Previous'),
                  ),
                  Text(
                    'Page $_currentPage of $_totalPages',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton.icon(
                    onPressed: _currentPage < _totalPages
                        ? () {
                            setState(() => _currentPage++);
                            _loadProducts();
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Next'),
                    iconAlignment: IconAlignment.end,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(AdminProduct product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showProductForm(product: product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 40),
                      ),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.text,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.formattedPrice,
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (product.alamat != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product.alamat!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showProductForm(product: product);
                  } else if (value == 'delete') {
                    _deleteProduct(product.id, product.title);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Product Form Dialog
class _ProductFormDialog extends ConsumerStatefulWidget {
  final AdminProduct? product;
  final VoidCallback onSaved;

  const _ProductFormDialog({
    this.product,
    required this.onSaved,
  });

  @override
  ConsumerState<_ProductFormDialog> createState() =>
      __ProductFormDialogState();
}

class __ProductFormDialogState extends ConsumerState<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _textController;
  late final TextEditingController _priceController;
  late final TextEditingController _alamatController;
  late final TextEditingController _nomorHpController;
  
  File? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title);
    _textController = TextEditingController(text: widget.product?.text);
    _priceController =
        TextEditingController(text: widget.product?.price.toString());
    _alamatController = TextEditingController(text: widget.product?.alamat);
    _nomorHpController = TextEditingController(text: widget.product?.nomorHp);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _priceController.dispose();
    _alamatController.dispose();
    _nomorHpController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final adminService = ref.read(adminServiceProvider);
      
      final productData = {
        'title': _titleController.text,
        'text': _textController.text,
        'price': int.parse(_priceController.text),
        'alamat': _alamatController.text,
        'nomor_hp': _nomorHpController.text,
      };

      // Create or update product
      final response = widget.product == null
          ? await adminService.createProduct(productData)
          : await adminService.updateProduct(widget.product!.id, productData);

      if (response['success'] == true) {
        // Upload image if selected
        if (_imageFile != null) {
          final productId = widget.product?.id ?? response['data']['id'] as int;
          await adminService.uploadProductImage(productId, _imageFile!.path);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.product == null
                    ? 'Produk berhasil ditambahkan'
                    : 'Produk berhasil diupdate',
              ),
            ),
          );
          widget.onSaved();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.product == null ? 'Tambah Produk' : 'Edit Produk',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Image Picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : widget.product?.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.product!.imageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate,
                                        size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Pilih Gambar',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Produk',
                      prefixIcon: Icon(Icons.shopping_bag),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama produk harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      prefixIcon: Icon(Icons.attach_money),
                      suffixText: 'Rp',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga harus diisi';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Harga harus berupa angka';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _alamatController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat (Opsional)',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nomorHpController,
                    decoration: const InputDecoration(
                      labelText: 'No. HP (Opsional)',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveProduct,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(widget.product == null ? 'Tambah' : 'Update'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
