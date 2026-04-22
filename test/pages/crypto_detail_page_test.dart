import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto_tracker_lite/pages/crypto_detail_page.dart';
import 'package:crypto_tracker_lite/bloc/crypto_detail_bloc.dart';
import 'package:crypto_tracker_lite/bloc/favorites_bloc.dart';
import 'package:crypto_tracker_lite/models/coin.dart';
import 'package:crypto_tracker_lite/models/coin_detail.dart';
import 'package:crypto_tracker_lite/models/market_chart.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../helpers/test_helper.dart';

class MockCryptoDetailBloc extends Mock implements CryptoDetailBloc {}
class MockFavoritesBloc extends Mock implements FavoritesBloc {}
class MockCacheManager extends Mock implements CacheManager {}

void main() {
  late MockCryptoDetailBloc mockCryptoDetailBloc;
  late MockFavoritesBloc mockFavoritesBloc;
  late MockCacheManager mockCacheManager;

  final dummyCoin = Coin(
    id: 'bitcoin',
    symbol: 'btc',
    name: 'Bitcoin',
    currentPrice: 50000.0,
    priceChangePercentage24h: 2.5,
    image: 'https://example.com/btc.png',
    high24h: 51000.0,
    low24h: 49000.0,
    marketCap: 1000000000,
    totalVolume: 50000000,
  );

  final dummyDetail = CoinDetail(
    description: 'The first cryptocurrency',
  );

  final dummyChart = MarketChart(
    prices: [[1620000000000.0, 50000.0], [1620086400000.0, 51000.0]],
  );

  setUpAll(() {
    setupMockImageHttp();
    setupMockPathProvider();
    registerFallbackValue(FetchCryptoDetail(''));
    registerFallbackValue(ToggleFavorite(''));
  });

  setUp(() {
    mockCryptoDetailBloc = MockCryptoDetailBloc();
    mockFavoritesBloc = MockFavoritesBloc();
    mockCacheManager = MockCacheManager();

    when(() => mockFavoritesBloc.state).thenReturn(FavoritesLoaded(const []));
    when(() => mockFavoritesBloc.stream).thenAnswer((_) => Stream.value(FavoritesLoaded(const [])));

    when(() => mockCacheManager.getFileStream(any(), key: any(named: 'key'), headers: any(named: 'headers'), withProgress: any(named: 'withProgress')))
        .thenAnswer((_) => Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<CryptoDetailBloc>.value(value: mockCryptoDetailBloc),
          BlocProvider<FavoritesBloc>.value(value: mockFavoritesBloc),
        ],
        child: CryptoDetailPage(coin: dummyCoin, cacheManager: mockCacheManager),
      ),
    );
  }

  testWidgets('CryptoDetailPage renders basic information correctly', (WidgetTester tester) async {
    when(() => mockCryptoDetailBloc.state).thenReturn(CryptoDetailInitial());
    when(() => mockCryptoDetailBloc.stream).thenAnswer((_) => Stream.value(CryptoDetailInitial()));

    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text('BTC'), findsOneWidget);
      expect(find.text('\$50000.00'), findsAtLeast(1));
    });
  });

  testWidgets('CryptoDetailPage shows loading indicator for detail', (WidgetTester tester) async {
    when(() => mockCryptoDetailBloc.state).thenReturn(CryptoDetailLoading());
    when(() => mockCryptoDetailBloc.stream).thenAnswer((_) => Stream.value(CryptoDetailLoading()));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsAtLeast(1));
  });

  testWidgets('CryptoDetailPage shows description and chart when loaded', (WidgetTester tester) async {
    when(() => mockCryptoDetailBloc.state).thenReturn(CryptoDetailLoaded(dummyChart, dummyDetail));
    when(() => mockCryptoDetailBloc.stream).thenAnswer((_) => Stream.value(CryptoDetailLoaded(dummyChart, dummyDetail)));

    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('The first cryptocurrency'), findsOneWidget);
      expect(find.text('Precio histórico (7 días)'), findsOneWidget);
    });
  });

  testWidgets('CryptoDetailPage shows rate limit error message', (WidgetTester tester) async {
    when(() => mockCryptoDetailBloc.state).thenReturn(CryptoDetailError('Error', isRateLimit: true));
    when(() => mockCryptoDetailBloc.stream).thenAnswer((_) => Stream.value(CryptoDetailError('Error', isRateLimit: true)));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Límite de API alcanzado. Espera unos segundos.'), findsOneWidget);
  });
}
