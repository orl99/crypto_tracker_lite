import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto_tracker_lite/bloc/crypto_detail_bloc.dart';
import 'package:crypto_tracker_lite/services/crypto_service.dart';
import 'package:crypto_tracker_lite/models/market_chart.dart';
import 'package:crypto_tracker_lite/models/coin_detail.dart';
import 'package:crypto_tracker_lite/api/exceptions.dart';

class MockCryptoService extends Mock implements CryptoService {}

void main() {
  late MockCryptoService mockCryptoService;
  late CryptoDetailBloc cryptoDetailBloc;

  final dummyChart = MarketChart(
    prices: [
      [123456789.0, 50000.0],
    ],
  );
  final dummyDetail = CoinDetail(
    description: 'Bitcoin is a decentralized digital currency',
  );

  setUp(() {
    mockCryptoService = MockCryptoService();
    cryptoDetailBloc = CryptoDetailBloc(mockCryptoService);
  });

  tearDown(() {
    cryptoDetailBloc.close();
  });

  group('CryptoDetailBloc Tests', () {
    test('initial state is CryptoDetailInitial', () {
      expect(cryptoDetailBloc.state, isA<CryptoDetailInitial>());
    });

    blocTest<CryptoDetailBloc, CryptoDetailState>(
      'emits [CryptoDetailLoading, CryptoDetailLoaded] when FetchCryptoDetail is successful',
      build: () {
        when(
          () => mockCryptoService.getMarketChart(any()),
        ).thenAnswer((_) async => dummyChart);
        when(
          () => mockCryptoService.getCoinDetail(any()),
        ).thenAnswer((_) async => dummyDetail);
        return cryptoDetailBloc;
      },
      act: (bloc) => bloc.add(FetchCryptoDetail('bitcoin')),
      expect: () => [
        isA<CryptoDetailLoading>(),
        isA<CryptoDetailLoaded>()
            .having((state) => state.chart, 'chart', dummyChart)
            .having((state) => state.detail, 'detail', dummyDetail)
            .having(
              (state) => state.isRateLimitExceeded,
              'isRateLimitExceeded',
              false,
            ),
      ],
    );

    blocTest<CryptoDetailBloc, CryptoDetailState>(
      'emits [CryptoDetailLoading, CryptoDetailError] when FetchCryptoDetail fails due to generic error',
      build: () {
        when(
          () => mockCryptoService.getMarketChart(any()),
        ).thenThrow(Exception('Network Error'));
        when(
          () => mockCryptoService.getCoinDetail(any()),
        ).thenAnswer((_) async => dummyDetail);
        return cryptoDetailBloc;
      },
      act: (bloc) => bloc.add(FetchCryptoDetail('bitcoin')),
      expect: () => [
        isA<CryptoDetailLoading>(),
        isA<CryptoDetailError>().having(
          (state) => state.isRateLimit,
          'isRateLimit',
          false,
        ),
      ],
    );

    blocTest<CryptoDetailBloc, CryptoDetailState>(
      'emits [CryptoDetailLoading, CryptoDetailError] with isRateLimit = true when RateLimitException is thrown',
      build: () {
        when(
          () => mockCryptoService.getMarketChart(any()),
        ).thenThrow(RateLimitException('Rate limit exceeded'));
        when(
          () => mockCryptoService.getCoinDetail(any()),
        ).thenAnswer((_) async => dummyDetail);
        return cryptoDetailBloc;
      },
      act: (bloc) => bloc.add(FetchCryptoDetail('bitcoin')),
      expect: () => [
        isA<CryptoDetailLoading>(),
        isA<CryptoDetailError>().having(
          (state) => state.isRateLimit,
          'isRateLimit',
          true,
        ),
      ],
    );

    blocTest<CryptoDetailBloc, CryptoDetailState>(
      'emits [CryptoDetailLoaded] with isRateLimitExceeded=true when RateLimitException occurs but data exists',
      build: () {
        // First, set up successful fetch
        when(
          () => mockCryptoService.getMarketChart(any()),
        ).thenAnswer((_) async => dummyChart);
        when(
          () => mockCryptoService.getCoinDetail(any()),
        ).thenAnswer((_) async => dummyDetail);
        return cryptoDetailBloc;
      },
      seed: () => CryptoDetailLoaded(dummyChart, dummyDetail),
      act: (bloc) {
        // Now set up to throw rate limit exception
        when(
          () => mockCryptoService.getMarketChart(any()),
        ).thenThrow(RateLimitException('Rate limit exceeded'));
        when(
          () => mockCryptoService.getCoinDetail(any()),
        ).thenThrow(RateLimitException('Rate limit exceeded'));
        bloc.add(FetchCryptoDetail('bitcoin'));
      },
      expect: () => [
        isA<CryptoDetailLoaded>().having(
          (state) => state.isRateLimitExceeded,
          'isRateLimitExceeded',
          true,
        ),
      ],
    );

    blocTest<CryptoDetailBloc, CryptoDetailState>(
      'emits [CryptoDetailLoaded] with isRateLimitExceeded=false when DismissRateLimitWarning is called',
      build: () {
        return cryptoDetailBloc;
      },
      seed: () => CryptoDetailLoaded(
        dummyChart,
        dummyDetail,
        isRateLimitExceeded: true,
      ),
      act: (bloc) => bloc.add(DismissRateLimitWarning()),
      expect: () => [
        isA<CryptoDetailLoaded>().having(
          (state) => state.isRateLimitExceeded,
          'isRateLimitExceeded',
          false,
        ),
      ],
    );
  });
}
