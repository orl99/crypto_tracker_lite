import 'dart:convert';
import 'package:http/http.dart' as http;
import 'exceptions.dart';

class ApiClient {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';
  final http.Client _client = http.Client();
  
  // Cache storage: URL -> CacheEntry
  final Map<String, _CacheEntry> _cache = {};
  
  final Duration cacheDuration = const Duration(seconds: 15);
  final Duration blockDuration = const Duration(seconds: 10);
  
  DateTime? _blockUntil;

  Future<dynamic> get(String endpoint) async {

    if (_blockUntil != null) {
      if (DateTime.now().isBefore(_blockUntil!)) {
        throw RateLimitException('Se superó el límite de peticiones. Por favor, espera.');
      } else {
        _blockUntil = null;
      }
    }

    final url = '$baseUrl$endpoint';

    if (_cache.containsKey(url)) {
      final entry = _cache[url]!;
      if (DateTime.now().difference(entry.timestamp) < cacheDuration) {
        return entry.data;
      }
    }

    try {
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _cache[url] = _CacheEntry(data: data, timestamp: DateTime.now());
        return data;
      } else if (response.statusCode == 429) {
        _blockUntil = DateTime.now().add(blockDuration);
        throw RateLimitException('Se superó el límite de peticiones. Por favor, espera.');
      } else {
        throw Exception('Failed to load data (Status ${response.statusCode})');
      }
    } catch (e) {
      if (e is RateLimitException) rethrow;
      throw Exception('Network error: $e');
    }
  }
}

class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  _CacheEntry({required this.data, required this.timestamp});
}
