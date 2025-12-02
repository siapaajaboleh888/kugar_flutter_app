import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import 'core/config/app_config.dart';

class ApiService {
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> _headers({bool withAuth = false}) {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (withAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/auth/login');
      developer.log('Login request to: $url');
      
      final res = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['data']?['token'] != null) {
        setToken(data['data']['token'] as String);
      }
      return data;
    } catch (e, stackTrace) {
      developer.log('Login error: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProduk({int page = 1}) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/produk?page=$page');
      developer.log('Fetching products from: $url');
      
      final res = await http.get(
        url, 
        headers: _headers()
      );
      
      if (res.statusCode != 200) {
        throw Exception('Failed to load products: ${res.statusCode}');
      }
      
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      developer.log('Error getting products: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProdukDetail(int id) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/produk/$id');
      developer.log('Fetching product detail from: $url');
      
      final res = await http.get(
        url, 
        headers: _headers()
      );
      
      if (res.statusCode != 200) {
        throw Exception('Failed to load product detail: ${res.statusCode}');
      }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAbout() async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/content/about');
      developer.log('Fetching about content from: $url');
      
      final res = await http.get(
        url, 
        headers: _headers()
      );
      
      if (res.statusCode != 200) {
        throw Exception('Failed to load about content: ${res.statusCode}');
      }
      
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      developer.log('Error getting about content: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
