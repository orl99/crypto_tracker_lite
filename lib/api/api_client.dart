import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'exceptions.dart';

/// [ApiClient] is responsible for managing all outgoing network requests to the CoinGecko API.
/// 
/// It implements two key mechanisms to ensure compliance with API policies and optimal performance:
/// 1. **In-Memory Caching**: Responses are stored in a local cache with a 15-second TTL 
///    to prevent redundant network calls for identical endpoints.
/// 2. **Rate Limit Handling**: Detects HTTP 429 status codes and implements a 10-second 
///    block duration, throwing a [RateLimitException] during the cooldown period.
class ApiClient {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();
  
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
    } on SocketException {
      throw Exception('No internet connection. Please check your settings.');
    } on FormatException {
      throw Exception('Invalid response format from server.');
    } catch (e) {
      if (e is RateLimitException) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }
}

/// Internal helper class to store cached response data along with its timestamp.
class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  _CacheEntry({required this.data, required this.timestamp});
}
