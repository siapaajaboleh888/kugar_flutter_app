import 'package:flutter/material.dart';

import 'api_service.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final ApiService _api = ApiService();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadAbout();
  }

  Future<void> _loadAbout() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.getAbout();
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _data = result['data'] as Map<String, dynamic>;
        });
      } else {
        setState(() {
          _error = 'Gagal memuat konten';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang KUGAR'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final about = _data?['about'];
    final documents = (_data?['documents'] as List?) ?? [];
    final pengurus = (_data?['pengurus'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Program KUGAR Pinggirpapas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (about != null)
            Text(
              about['description']?.toString() ?? about.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            Text(
              'Platform e-business untuk pemberdayaan petambak garam di Desa Pinggirpapas, Sumenep.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 24),
          if (documents.isNotEmpty) ...[
            Text(
              'Dokumen Terkait',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ...documents.map((doc) {
              final map = doc as Map<String, dynamic>;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(map['title']?.toString() ?? '-'),
                subtitle: Text(map['description']?.toString() ?? ''),
              );
            }),
            const SizedBox(height: 24),
          ],
          if (pengurus.isNotEmpty) ...[
            Text(
              'Pengurus KUGAR',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ...pengurus.map((p) {
              final map = p as Map<String, dynamic>;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(map['nama']?.toString() ?? '-'),
                subtitle: Text(map['jabatan']?.toString() ?? ''),
              );
            }),
          ],
        ],
      ),
    );
  }
}
