import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites_list';
  final SharedPreferences _prefs;

  FavoritesService(this._prefs);

  List<String> getFavorites() {
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> addFavorite(String coinId) async {
    final favorites = getFavorites();
    if (!favorites.contains(coinId)) {
      favorites.add(coinId);
      await _prefs.setStringList(_favoritesKey, favorites);
    }
  }

  Future<void> removeFavorite(String coinId) async {
    final favorites = getFavorites();
    if (favorites.contains(coinId)) {
      favorites.remove(coinId);
      await _prefs.setStringList(_favoritesKey, favorites);
    }
  }

  Future<void> toggleFavorite(String coinId) async {
    final favorites = getFavorites();
    if (favorites.contains(coinId)) {
      favorites.remove(coinId);
    } else {
      favorites.add(coinId);
    }
    await _prefs.setStringList(_favoritesKey, favorites);
  }
  
  bool isFavorite(String coinId) {
    return getFavorites().contains(coinId);
  }
}
