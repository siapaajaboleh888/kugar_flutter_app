import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';

const baseUrl = 'http://127.0.0.1:3001/api';

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
    final url = Uri.parse('$baseUrl/auth/login');
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
  }

  Future<Map<String, dynamic>> getProduk({int page = 1}) async {
    final url = Uri.parse('$baseUrl/produk?page=$page');
    final res = await http.get(url, headers: _headers());
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProdukDetail(int id) async {
    final url = Uri.parse('$baseUrl/produk/$id');
    final res = await http.get(url, headers: _headers());
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAbout() async {
    final url = Uri.parse('$baseUrl/content/about');
    final res = await http.get(url, headers: _headers());
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
