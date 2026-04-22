import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto_tracker_lite/pages/home_page.dart';
import 'package:crypto_tracker_lite/bloc/crypto_list_bloc.dart';
import 'package:crypto_tracker_lite/bloc/favorites_bloc.dart';
import 'package:crypto_tracker_lite/models/coin.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../helpers/test_helper.dart';

class MockCryptoListBloc extends Mock implements CryptoListBloc {}
class MockFavoritesBloc extends Mock implements FavoritesBloc {}
class MockCacheManager extends Mock implements CacheManager {}

void main() {
  late MockCryptoListBloc mockCryptoListBloc;
  late MockFavoritesBloc mockFavoritesBloc;
  late MockCacheManager mockCacheManager;

  final dummyCoins = [
    Coin(
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
    ),
  ];

  setUpAll(() {
    setupMockImageHttp();
    setupMockPathProvider();
    registerFallbackValue(FetchCryptoList());
    registerFallbackValue(DismissRateLimitWarning());
    registerFallbackValue(ToggleFavorite(''));
  });

  setUp(() {
    mockCryptoListBloc = MockCryptoListBloc();
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
          BlocProvider<CryptoListBloc>.value(value: mockCryptoListBloc),
          BlocProvider<FavoritesBloc>.value(value: mockFavoritesBloc),
        ],
        child: HomePage(cacheManager: mockCacheManager),
      ),
    );
  }

  testWidgets('HomePage shows loading indicator', (WidgetTester tester) async {
    when(() => mockCryptoListBloc.state).thenReturn(CryptoListLoading());
    when(() => mockCryptoListBloc.stream).thenAnswer((_) => Stream.value(CryptoListLoading()));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('HomePage shows list of coins when loaded', (WidgetTester tester) async {
    when(() => mockCryptoListBloc.state).thenReturn(CryptoListLoaded(dummyCoins));
    when(() => mockCryptoListBloc.stream).thenAnswer((_) => Stream.value(CryptoListLoaded(dummyCoins)));

    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text('BTC'), findsOneWidget);
    });
  });

  testWidgets('HomePage shows rate limit warning banner when exceeded', (WidgetTester tester) async {
    when(() => mockCryptoListBloc.state).thenReturn(CryptoListLoaded(dummyCoins, isRateLimitExceeded: true));
    when(() => mockCryptoListBloc.stream).thenAnswer((_) => Stream.value(CryptoListLoaded(dummyCoins, isRateLimitExceeded: true)));

    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.textContaining('Límite de solicitudes excedido'), findsOneWidget);
    });
  });

  testWidgets('HomePage shows error widget on rate limit error', (WidgetTester tester) async {
    when(() => mockCryptoListBloc.state).thenReturn(CryptoListError('Rate limit', isRateLimit: true));
    when(() => mockCryptoListBloc.stream).thenAnswer((_) => Stream.value(CryptoListError('Rate limit', isRateLimit: true)));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.textContaining('Hubo un problema'), findsOneWidget);
  });
}
