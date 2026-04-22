import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto_tracker_lite/widgets/coin_list_tile.dart';
import 'package:crypto_tracker_lite/models/coin.dart';
import 'package:crypto_tracker_lite/bloc/favorites_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../helpers/test_helper.dart';

class MockFavoritesBloc extends Mock implements FavoritesBloc {}
class MockCacheManager extends Mock implements CacheManager {}

void main() {
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

  setUpAll(() {
    setupMockImageHttp();
    setupMockPathProvider();
    registerFallbackValue(ToggleFavorite(''));
  });

  setUp(() {
    mockFavoritesBloc = MockFavoritesBloc();
    mockCacheManager = MockCacheManager();
    
    when(() => mockFavoritesBloc.state).thenReturn(FavoritesLoaded(const []));
    when(() => mockFavoritesBloc.stream).thenAnswer((_) => Stream.value(FavoritesLoaded(const [])));
    
    // Stub for CachedNetworkImage
    when(() => mockCacheManager.getFileStream(any(), key: any(named: 'key'), headers: any(named: 'headers'), withProgress: any(named: 'withProgress')))
        .thenAnswer((_) => Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      locale: const Locale('es'),
      supportedLocales: testSupportedLocales,
      localizationsDelegates: testLocalizationDelegates,
      home: Scaffold(
        body: BlocProvider<FavoritesBloc>.value(
          value: mockFavoritesBloc,
          child: CoinListTile(coin: dummyCoin, cacheManager: mockCacheManager),
        ),
      ),
    );
  }

  testWidgets('CoinListTile renders coin information correctly', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text('BTC'), findsOneWidget);
      expect(find.text('\$50000.00'), findsOneWidget);
      expect(find.text('+2.50%'), findsOneWidget);
    });
  });

  testWidgets('CoinListTile shows filled star when coin is favorite', (WidgetTester tester) async {
    when(() => mockFavoritesBloc.state).thenReturn(FavoritesLoaded(const ['bitcoin']));
    
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNothing);
    });
  });

  testWidgets('CoinListTile shows empty star when coin is not favorite', (WidgetTester tester) async {
    when(() => mockFavoritesBloc.state).thenReturn(FavoritesLoaded(const []));
    
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);
    });
  });

  testWidgets('Tapping star icon adds ToggleFavorite event', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Tap the GestureDetector that wraps the star icon
      await tester.tap(find.byIcon(Icons.star_border));
      verify(() => mockFavoritesBloc.add(any(that: isA<ToggleFavorite>()))).called(1);
    });
  });
}
