import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';

// Centralized API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
