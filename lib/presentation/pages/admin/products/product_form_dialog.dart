import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/admin_service.dart';

class ProductFormDialog extends StatefulWidget {
  final AdminService adminService;
  final Map<String, dynamic>? product; // null for create, non-null for edit

  const ProductFormDialog({
    super.key,
    required this.adminService,
    this.product,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;
  late TextEditingController _hargaController;
  late TextEditingController _stokController;
  late TextEditingController _beratController;
  late TextEditingController _gambarController;
  
  String _selectedKategori = 'garam';
  bool _isLoading = false;
  bool get _isEditMode => widget.product != null;

  final List<String> _kategoriOptions = [
    'garam',
    'seafood',
    'kerajinan',
    'lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(
      text: widget.product?['nama'] as String? ?? '',
    );
    _deskripsiController = TextEditingController(
      text: widget.product?['deskripsi'] as String? ?? '',
    );
    _hargaController = TextEditingController(
      text: widget.product?['harga']?.toString() ?? '',
    );
    _stokController = TextEditingController(
      text: widget.product?['stok']?.toString() ?? '',
    );
    _beratController = TextEditingController(
      text: widget.product?['berat']?.toString() ?? '',
    );
    _gambarController = TextEditingController(
      text: widget.product?['gambar'] as String? ?? '',
    );
    _selectedKategori = widget.product?['kategori'] as String? ?? 'garam';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _beratController.dispose();
    _gambarController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final productData = {
        'nama': _namaController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'harga': double.parse(_hargaController.text),
        'stok': int.parse(_stokController.text),
        'berat': _beratController.text.isNotEmpty 
            ? double.parse(_beratController.text)
            : null,
        'kategori': _selectedKategori,
        'gambar': _gambarController.text.trim().isNotEmpty 
            ? _gambarController.text.trim() 
            : null,
      };

      if (_isEditMode) {
        final productId = widget.product!['id'] as int;
        await widget.adminService.updateProduct(productId, productData);
      } else {
        await widget.adminService.createProduct(productData);
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode 
                  ? 'Produk berhasil diupdate' 
                  : 'Produk berhasil ditambahkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan produk: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _isEditMode ? 'Edit Produk' : 'Tambah Produk Baru',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Nama Produk
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Produk *',
                      hintText: 'Masukkan nama produk',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory_2),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama produk harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Deskripsi
                  TextFormField(
                    controller: _deskripsiController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      hintText: 'Masukkan deskripsi produk',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Kategori
                  DropdownButtonFormField<String>(
                    value: _selectedKategori,
                    decoration: const InputDecoration(
                      labelText: 'Kategori *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _kategoriOptions.map((kategori) {
                      return DropdownMenuItem(
                        value: kategori,
                        child: Text(kategori.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedKategori = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Harga dan Stok (Row)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _hargaController,
                          decoration: const InputDecoration(
                            labelText: 'Harga *',
                            hintText: '0',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                            prefixText: 'Rp ',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Harga harus diisi';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Harga tidak valid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stokController,
                          decoration: const InputDecoration(
                            labelText: 'Stok *',
                            hintText: '0',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.inventory),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Stok harus diisi';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Stok tidak valid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Berat (optional)
                  TextFormField(
                    controller: _beratController,
                    decoration: const InputDecoration(
                      labelText: 'Berat (gram)',
                      hintText: '0',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scale),
                      suffixText: 'gram',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // URL Gambar (optional)
                  TextFormField(
                    controller: _gambarController,
                    decoration: const InputDecoration(
                      labelText: 'URL Gambar',
                      hintText: 'https://example.com/image.jpg',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.image),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_isEditMode ? 'Update' : 'Tambah'),
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
