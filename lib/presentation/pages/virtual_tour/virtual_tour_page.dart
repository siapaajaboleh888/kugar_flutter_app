import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter/webview_flutter.dart';

class VirtualTourPage extends ConsumerStatefulWidget {
  final String? tourUrl;
  
  const VirtualTourPage({super.key, this.tourUrl});

  @override
  ConsumerState<VirtualTourPage> createState() => _VirtualTourPageState();
}

class _VirtualTourPageState extends ConsumerState<VirtualTourPage> {
  bool _isLoading = true;
  final String _title = 'Virtual Tour';
  late final WebViewController _webViewController;
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }
  
  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading indicator if needed
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.tourUrl ?? 'https://kugar.e-pinggirpapas-sumenep.com/virtual-tour'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewController.reload();
            },
          ),
        ],
      ),
      body: kIsWeb ? _buildWebContent() : _buildMobileContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTourInfo();
        },
        child: const Icon(Icons.info_outline),
      ),
    );
  }
  
  Widget _buildWebContent() {
    // Gunakan WebView untuk web dan mobile
    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        if (_isLoading)
          Container(
            color: Colors.white,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Virtual Tour...'),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildMobileContent() {
    // Untuk mobile, gunakan WebView atau tampilkan pesan
    return const Center(
      child: Text('Virtual Tour hanya tersedia di platform web'),
    );
  }

  void _showTourInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Virtual Tour'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Explore our facilities in 360°'),
            SizedBox(height: 8),
            Text('• Navigate through different areas'),
            Text('• Click on hotspots for more information'),
            Text('• Use mouse/touch to look around'),
            SizedBox(height: 8),
            Text('Best viewed in landscape mode'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
