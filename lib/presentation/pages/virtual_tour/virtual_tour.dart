import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class VirtualTour {
  final int id;
  final String title;
  final String description;
  final String? thumbnail;
  final String link;
  final bool isActive;
  final int order;

  VirtualTour({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnail,
    required this.link,
    required this.isActive,
    required this.order,
  });

  factory VirtualTour.fromJson(Map<String, dynamic> json) {
    return VirtualTour(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      thumbnail: json['thumbnail'],
      link: json['link'] ?? '',
      isActive: (json['is_active'] ?? 0) == 1,
      order: json['order'] ?? 0,
    );
  }
}

class VirtualTourProvider extends ChangeNotifier {
  List<VirtualTour> _tours = [];
  bool _isLoading = false;
  String? _error;

  List<VirtualTour> get tours => _tours;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTours() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://wisatalembung.test/api/virtual-tour'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['data'] != null) {
          _tours = (jsonData['data'] as List)
              .map((item) => VirtualTour.fromJson(item))
              .toList();
        } else {
          _error = 'Format data tidak valid';
        }
      } else {
        _error = 'Gagal memuat data: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

final virtualTourProvider = ChangeNotifierProvider<VirtualTourProvider>((ref) {
  return VirtualTourProvider();
});

class VirtualTourPage extends ConsumerStatefulWidget {
  const VirtualTourPage({Key? key}) : super(key: key);

  @override
  ConsumerState<VirtualTourPage> createState() => _VirtualTourPageState();
}

class _VirtualTourPageState extends ConsumerState<VirtualTourPage> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    // Memuat data saat pertama kali dibuka
    Future.microtask(() => ref.read(virtualTourProvider).fetchTours());
  }

  Future<void> _launchURL(String url, BuildContext context) async {
    if (url.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link tidak tersedia')),
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!launched && context.mounted) {
          throw 'Gagal membuka browser';
        }
      } else {
        throw 'Tidak dapat membuka tautan ini';
      }
    } on FormatException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Format URL tidak valid: ${e.message}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat membuka link: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tourProvider = ref.watch(virtualTourProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Tour'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: tourProvider.isLoading
                ? null
                : () => _refreshKey.currentState?.show(),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: () => tourProvider.fetchTours(),
        child: _buildContent(tourProvider, context),
      ),
    );
  }

  Widget _buildContent(VirtualTourProvider tourProvider, BuildContext context) {
    if (tourProvider.isLoading && tourProvider.tours.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tourProvider.error != null) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.signal_wifi_off, size: 64, color: Colors.grey),
                const SizedBox(height: 24),
                const Text(
                  'Gagal Memuat Data',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  tourProvider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: tourProvider.isLoading
                      ? null
                      : () => tourProvider.fetchTours(),
                  icon: const Icon(Icons.refresh),
                  label: Text(tourProvider.isLoading ? 'Memuat...' : 'Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (tourProvider.tours.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Virtual Tour',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Saat ini belum ada virtual tour yang tersedia',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => tourProvider.fetchTours(),
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: tourProvider.tours.length,
      itemBuilder: (context, index) {
        final tour = tourProvider.tours[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _launchURL(tour.link, context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (tour.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      tour.description,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () => _launchURL(tour.link, context),
                      icon: const Icon(Icons.play_arrow, size: 24),
                      label: const Text('MULAI VIRTUAL TOUR', 
                        style: TextStyle(letterSpacing: 0.5),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
