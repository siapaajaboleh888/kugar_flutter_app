import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VirtualTourPage extends ConsumerStatefulWidget {
  final String? tourUrl;
  
  const VirtualTourPage({super.key, this.tourUrl});

  @override
  ConsumerState<VirtualTourPage> createState() => _VirtualTourPageState();
}

class _VirtualTourPageState extends ConsumerState<VirtualTourPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  final String _title = 'Virtual Tour';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading indicator
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
            // Handle error
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation for virtual tour
            return NavigationDecision.navigate;
          },
        ),
      );

    // Load virtual tour URL
    final url = widget.tourUrl ?? 'https://kugar.e-pinggirpapas-sumenep.com/virtual-tour';
    _controller.loadRequest(Uri.parse(url));
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
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTourInfo();
        },
        child: const Icon(Icons.info_outline),
      ),
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
