import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:crypto_tracker_lite/api/api_client.dart';
import 'package:crypto_tracker_lite/api/exceptions.dart';

void main() {
  group('ApiClient', () {
    test('returns parsed data when response is 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode({'status': 'ok'}), 200);
      });

      final apiClient = ApiClient(client: mockClient);
      final result = await apiClient.get('/test');

      expect(result, isA<Map>());
      expect(result['status'], 'ok');
    });

    test('returns cached data when the same URL is called twice within 15s', () async {
      int callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        return http.Response(json.encode({'call': callCount}), 200);
      });

      final apiClient = ApiClient(client: mockClient);

      final result1 = await apiClient.get('/cached-endpoint');
      final result2 = await apiClient.get('/cached-endpoint');

      // Both calls should return the same data (from cache)
      expect(result1['call'], 1);
      expect(result2['call'], 1);
      // Only one real HTTP call was made
      expect(callCount, 1);
    });

    test('makes separate HTTP calls for different endpoints', () async {
      int callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        return http.Response(json.encode({'call': callCount}), 200);
      });

      final apiClient = ApiClient(client: mockClient);

      await apiClient.get('/endpoint-a');
      await apiClient.get('/endpoint-b');

      // Two different endpoints = two real HTTP calls
      expect(callCount, 2);
    });

    test('throws RateLimitException when response status is 429', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Too Many Requests', 429);
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () => apiClient.get('/rate-limited'),
        throwsA(isA<RateLimitException>()),
      );
    });

    test('blocks subsequent requests immediately after a 429 (within blockDuration)', () async {
      int callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          return http.Response('Too Many Requests', 429);
        }
        return http.Response(json.encode({'status': 'ok'}), 200);
      });

      final apiClient = ApiClient(client: mockClient);

      // First call: receives 429
      try {
        await apiClient.get('/blocked');
      } catch (_) {}

      // Immediate second call: must throw RateLimitException
      // without reaching the network (_blockUntil guard)
      expect(
        () => apiClient.get('/another-endpoint'),
        throwsA(isA<RateLimitException>()),
      );

      // Only 1 real HTTP call was made (second was blocked before hitting the network)
      expect(callCount, 1);
    });

    test('throws generic Exception for non-429 HTTP error codes', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () => apiClient.get('/server-error'),
        throwsA(isA<Exception>()),
      );
    });

    test('throws Exception on network failure', () async {
      final mockClient = MockClient((request) async {
        throw Exception('No internet connection');
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () => apiClient.get('/network-fail'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
