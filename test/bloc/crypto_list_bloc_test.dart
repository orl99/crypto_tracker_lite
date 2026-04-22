import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto_tracker_lite/bloc/crypto_list_bloc.dart';
import 'package:crypto_tracker_lite/services/crypto_service.dart';
import 'package:crypto_tracker_lite/models/coin.dart';
import 'package:crypto_tracker_lite/api/exceptions.dart';

class MockCryptoService extends Mock implements CryptoService {}

void main() {
  late MockCryptoService mockCryptoService;
  late CryptoListBloc cryptoListBloc;

  final List<Coin> dummyCoins = [
    Coin(
        id: 'bitcoin',
        symbol: 'btc',
        name: 'Bitcoin',
        currentPrice: 50000,
        priceChangePercentage24h: 2.5,
        image: 'http://example.com/bitcoin.png',
        high24h: 51000,
        low24h: 49000,
        marketCap: 1000000000,
        totalVolume: 50000000),
  ];

  setUp(() {
    mockCryptoService = MockCryptoService();
    cryptoListBloc = CryptoListBloc(mockCryptoService);
  });

  tearDown(() {
    cryptoListBloc.close();
  });

  group('CryptoListBloc Tests', () {
    test('initial state is CryptoListInitial', () {
      expect(cryptoListBloc.state, isA<CryptoListInitial>());
    });

    blocTest<CryptoListBloc, CryptoListState>(
      'emits [CryptoListLoading, CryptoListLoaded] when FetchCryptoList is successful',
      build: () {
        when(() => mockCryptoService.getMarkets())
            .thenAnswer((_) async => dummyCoins);
        return cryptoListBloc;
      },
      act: (bloc) => bloc.add(FetchCryptoList()),
      expect: () => [
        isA<CryptoListLoading>(),
        isA<CryptoListLoaded>()
            .having((state) => state.coins, 'coins', dummyCoins)
            .having((state) => state.isRateLimitExceeded, 'isRateLimitExceeded', false),
      ],
    );

    blocTest<CryptoListBloc, CryptoListState>(
      'emits [CryptoListLoading, CryptoListError] when FetchCryptoList fails due to network error',
      build: () {
        when(() => mockCryptoService.getMarkets())
            .thenThrow(Exception('Network Error'));
        return cryptoListBloc;
      },
      act: (bloc) => bloc.add(FetchCryptoList()),
      expect: () => [
        isA<CryptoListLoading>(),
        isA<CryptoListError>()
            .having((state) => state.isRateLimit, 'isRateLimit', false),
      ],
    );

    blocTest<CryptoListBloc, CryptoListState>(
      'emits [CryptoListLoading, CryptoListError] with isRateLimit=true when RateLimitException occurs without previous data',
      build: () {
        when(() => mockCryptoService.getMarkets())
            .thenThrow(RateLimitException('Rate limit exceeded'));
        return cryptoListBloc;
      },
      act: (bloc) => bloc.add(FetchCryptoList()),
      expect: () => [
        isA<CryptoListLoading>(),
        isA<CryptoListError>()
            .having((state) => state.isRateLimit, 'isRateLimit', true),
      ],
    );

    blocTest<CryptoListBloc, CryptoListState>(
      'emits [CryptoListLoaded] with isRateLimitExceeded=true when RateLimitException occurs with previous data',
      build: () {
        when(() => mockCryptoService.getMarkets())
            .thenThrow(RateLimitException('Rate limit exceeded'));
        return cryptoListBloc;
      },
      seed: () => CryptoListLoaded(dummyCoins),
      act: (bloc) => bloc.add(FetchCryptoList()),
      expect: () => [
        isA<CryptoListLoaded>()
            .having((state) => state.coins, 'coins', dummyCoins)
            .having((state) => state.isRateLimitExceeded, 'isRateLimitExceeded', true),
      ],
    );

    blocTest<CryptoListBloc, CryptoListState>(
      'emits [CryptoListLoaded] with isRateLimitExceeded=false when DismissRateLimitWarning is added',
      build: () {
        return cryptoListBloc;
      },
      seed: () => CryptoListLoaded(dummyCoins, isRateLimitExceeded: true),
      act: (bloc) => bloc.add(DismissRateLimitWarning()),
      expect: () => [
        isA<CryptoListLoaded>()
            .having((state) => state.coins, 'coins', dummyCoins)
            .having((state) => state.isRateLimitExceeded, 'isRateLimitExceeded', false),
      ],
    );
  });
}
