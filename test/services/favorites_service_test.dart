import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_tracker_lite/services/favorites_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late FavoritesService favoritesService;
  const String favoritesKey = 'favorites_list';

  setUp(() {
    mockPrefs = MockSharedPreferences();
    favoritesService = FavoritesService(mockPrefs);
  });

  group('FavoritesService Tests', () {
    test('getFavorites returns empty list when nothing is stored', () {
      when(() => mockPrefs.getStringList(favoritesKey)).thenReturn(null);
      
      final result = favoritesService.getFavorites();
      
      expect(result, isEmpty);
    });

    test('addFavorite adds an ID to the list', () async {
      when(() => mockPrefs.getStringList(favoritesKey)).thenReturn(['bitcoin']);
      when(() => mockPrefs.setStringList(any(), any())).thenAnswer((_) async => true);

      await favoritesService.addFavorite('ethereum');

      verify(() => mockPrefs.setStringList(favoritesKey, ['bitcoin', 'ethereum'])).called(1);
    });

    test('removeFavorite removes an ID from the list', () async {
      when(() => mockPrefs.getStringList(favoritesKey)).thenReturn(['bitcoin', 'ethereum']);
      when(() => mockPrefs.setStringList(any(), any())).thenAnswer((_) async => true);

      await favoritesService.removeFavorite('bitcoin');

      verify(() => mockPrefs.setStringList(favoritesKey, ['ethereum'])).called(1);
    });

    test('toggleFavorite adds ID if not present', () async {
      when(() => mockPrefs.getStringList(favoritesKey)).thenReturn(['bitcoin']);
      when(() => mockPrefs.setStringList(any(), any())).thenAnswer((_) async => true);

      await favoritesService.toggleFavorite('ethereum');

      verify(() => mockPrefs.setStringList(favoritesKey, ['bitcoin', 'ethereum'])).called(1);
    });

    test('toggleFavorite removes ID if present', () async {
      when(() => mockPrefs.getStringList(favoritesKey)).thenReturn(['bitcoin', 'ethereum']);
      when(() => mockPrefs.setStringList(any(), any())).thenAnswer((_) async => true);

      await favoritesService.toggleFavorite('bitcoin');

      verify(() => mockPrefs.setStringList(favoritesKey, ['ethereum'])).called(1);
    });

    test('isFavorite returns correct status', () {
      when(() => mockPrefs.getStringList(favoritesKey)).thenReturn(['bitcoin']);
      
      expect(favoritesService.isFavorite('bitcoin'), isTrue);
      expect(favoritesService.isFavorite('ethereum'), isFalse);
    });
  });
}
