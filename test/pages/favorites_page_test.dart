import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto_tracker_lite/pages/favorites_page.dart';
import 'package:crypto_tracker_lite/bloc/crypto_list_bloc.dart';
import 'package:crypto_tracker_lite/bloc/crypto_detail_bloc.dart';
import 'package:crypto_tracker_lite/bloc/favorites_bloc.dart';
import 'package:crypto_tracker_lite/models/coin.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../helpers/test_helper.dart';

class MockCryptoListBloc extends Mock implements CryptoListBloc {}

class MockCryptoDetailBloc extends Mock implements CryptoDetailBloc {}

class MockFavoritesBloc extends Mock implements FavoritesBloc {}

class MockCacheManager extends Mock implements CacheManager {}

void main() {
  late MockCryptoListBloc mockCryptoListBloc;
  late MockCryptoDetailBloc mockCryptoDetailBloc;
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
    Coin(
      id: 'ethereum',
      symbol: 'eth',
      name: 'Ethereum',
      currentPrice: 3000.0,
      priceChangePercentage24h: 1.5,
      image: 'https://example.com/eth.png',
      high24h: 3100.0,
      low24h: 2900.0,
      marketCap: 400000000,
      totalVolume: 20000000,
    ),
  ];

  setUpAll(() {
    setupMockImageHttp();
    setupMockPathProvider();
    registerFallbackValue(FetchCryptoList());
    registerFallbackValue(FetchCryptoDetail(''));
    registerFallbackValue(ToggleFavorite(''));
  });

  setUp(() {
    mockCryptoListBloc = MockCryptoListBloc();
    mockCryptoDetailBloc = MockCryptoDetailBloc();
    mockFavoritesBloc = MockFavoritesBloc();
    mockCacheManager = MockCacheManager();

    when(() => mockCryptoDetailBloc.state).thenReturn(CryptoDetailInitial());
    when(
      () => mockCryptoDetailBloc.stream,
    ).thenAnswer((_) => Stream.value(CryptoDetailInitial()));

    when(
      () => mockCryptoListBloc.state,
    ).thenReturn(CryptoListLoaded(dummyCoins));
    when(
      () => mockCryptoListBloc.stream,
    ).thenAnswer((_) => Stream.value(CryptoListLoaded(dummyCoins)));

    when(
      () => mockCacheManager.getFileStream(
        any(),
        key: any(named: 'key'),
        headers: any(named: 'headers'),
        withProgress: any(named: 'withProgress'),
      ),
    ).thenAnswer((_) => Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      locale: const Locale('es'),
      supportedLocales: testSupportedLocales,
      localizationsDelegates: testLocalizationDelegates,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<CryptoListBloc>.value(value: mockCryptoListBloc),
          BlocProvider<CryptoDetailBloc>.value(value: mockCryptoDetailBloc),
          BlocProvider<FavoritesBloc>.value(value: mockFavoritesBloc),
        ],
        child: FavoritesPage(cacheManager: mockCacheManager),
      ),
    );
  }

  testWidgets('FavoritesPage shows empty state when no favorites', (
    WidgetTester tester,
  ) async {
    when(() => mockFavoritesBloc.state).thenReturn(FavoritesLoaded([]));
    when(
      () => mockFavoritesBloc.stream,
    ).thenAnswer((_) => Stream.value(FavoritesLoaded([])));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Aún no tienes favoritos'), findsOneWidget);
  });

  testWidgets('FavoritesPage shows only favorite coins', (
    WidgetTester tester,
  ) async {
    // Only Bitcoin is favorite
    when(
      () => mockFavoritesBloc.state,
    ).thenReturn(FavoritesLoaded(['bitcoin']));
    when(
      () => mockFavoritesBloc.stream,
    ).thenAnswer((_) => Stream.value(FavoritesLoaded(['bitcoin'])));

    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text('Ethereum'), findsNothing);
    });
  });

  testWidgets('FavoritesPage shows multiple favorite coins', (
    WidgetTester tester,
  ) async {
    when(
      () => mockFavoritesBloc.state,
    ).thenReturn(FavoritesLoaded(['bitcoin', 'ethereum']));
    when(
      () => mockFavoritesBloc.stream,
    ).thenAnswer((_) => Stream.value(FavoritesLoaded(['bitcoin', 'ethereum'])));

    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text('Ethereum'), findsOneWidget);
    });
  });
}
