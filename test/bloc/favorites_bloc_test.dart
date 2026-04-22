import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto_tracker_lite/bloc/favorites_bloc.dart';
import 'package:crypto_tracker_lite/services/favorites_service.dart';

class MockFavoritesService extends Mock implements FavoritesService {}

void main() {
  late MockFavoritesService mockFavoritesService;
  late FavoritesBloc favoritesBloc;

  setUp(() {
    mockFavoritesService = MockFavoritesService();
    favoritesBloc = FavoritesBloc(mockFavoritesService);
  });

  tearDown(() {
    favoritesBloc.close();
  });

  group('FavoritesBloc Tests', () {
    test('initial state is FavoritesLoaded with empty list', () {
      expect(favoritesBloc.state, isA<FavoritesLoaded>().having((s) => s.favoriteIds, 'favoriteIds', isEmpty));
    });

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoritesLoaded] when LoadFavorites is added',
      build: () {
        when(() => mockFavoritesService.getFavorites()).thenReturn(['bitcoin', 'ethereum']);
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(LoadFavorites()),
      expect: () => [
        isA<FavoritesLoaded>().having((s) => s.favoriteIds, 'favoriteIds', ['bitcoin', 'ethereum']),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoritesLoaded] when ToggleFavorite is added',
      build: () {
        when(() => mockFavoritesService.toggleFavorite(any())).thenAnswer((_) async {});
        when(() => mockFavoritesService.getFavorites()).thenReturn(['bitcoin']);
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(ToggleFavorite('bitcoin')),
      expect: () => [
        isA<FavoritesLoaded>().having((s) => s.favoriteIds, 'favoriteIds', ['bitcoin']),
      ],
      verify: (_) {
        verify(() => mockFavoritesService.toggleFavorite('bitcoin')).called(1);
      },
    );
  });
}
