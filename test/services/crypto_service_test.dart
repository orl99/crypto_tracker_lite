import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto_tracker_lite/services/crypto_service.dart';
import 'package:crypto_tracker_lite/api/api_client.dart';
import 'package:crypto_tracker_lite/models/coin.dart';
import 'package:crypto_tracker_lite/models/market_chart.dart';
import 'package:crypto_tracker_lite/models/coin_detail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late CryptoService cryptoService;

  setUp(() {
    mockApiClient = MockApiClient();
    cryptoService = CryptoService(mockApiClient);
  });

  group('CryptoService Tests', () {
    test('getMarkets returns a list of coins on success', () async {
      final dummyResponse = [
        {
          'id': 'bitcoin',
          'symbol': 'btc',
          'name': 'Bitcoin',
          'current_price': 50000.0,
          'price_change_percentage_24h': 2.5,
          'image': 'https://example.com/btc.png',
          'high_24h': 51000.0,
          'low_24h': 49000.0,
          'market_cap': 1000000000,
          'total_volume': 50000000,
        }
      ];

      when(() => mockApiClient.get(any())).thenAnswer((_) async => dummyResponse);

      final result = await cryptoService.getMarkets();

      expect(result, isA<List<Coin>>());
      expect(result.length, 1);
      expect(result.first.id, 'bitcoin');
      verify(() => mockApiClient.get(any(that: contains('/coins/markets')))).called(1);
    });

    test('getMarketChart returns a MarketChart object on success', () async {
      final dummyResponse = {
        'prices': [
          [123456789.0, 50000.0]
        ]
      };

      when(() => mockApiClient.get(any())).thenAnswer((_) async => dummyResponse);

      final result = await cryptoService.getMarketChart('bitcoin');

      expect(result, isA<MarketChart>());
      expect(result.prices.length, 1);
      verify(() => mockApiClient.get(any(that: contains('/market_chart')))).called(1);
    });

    test('getCoinDetail returns a CoinDetail object on success', () async {
      final dummyResponse = {
        'description': {
          'en': 'Bitcoin is a decentralized digital currency'
        }
      };

      when(() => mockApiClient.get(any())).thenAnswer((_) async => dummyResponse);

      final result = await cryptoService.getCoinDetail('bitcoin');

      expect(result, isA<CoinDetail>());
      expect(result.description, contains('Bitcoin'));
      verify(() => mockApiClient.get(any(that: contains('/coins/bitcoin')))).called(1);
    });
  });
}
