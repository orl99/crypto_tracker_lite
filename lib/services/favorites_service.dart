import 'package:shared_preferences/shared_preferences.dart';

/// [FavoritesService] manages the local persistence of favorite cryptocurrencies.
/// 
/// It uses [SharedPreferences] to store a list of coin identifiers, ensuring 
/// that user preferences are maintained even after the app is closed.
class FavoritesService {
  static const String _favoritesKey = 'favorites_list';
  final SharedPreferences _prefs;

  /// Creates a [FavoritesService] with a required [SharedPreferences] instance.
  FavoritesService(this._prefs);

  /// Retrieves the list of favorite coin IDs from local storage.
  /// 
  /// Returns an empty list if no favorites have been saved yet.
  List<String> getFavorites() {
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  /// Adds a [coinId] to the favorites list if it's not already present.
  Future<void> addFavorite(String coinId) async {
    final favorites = getFavorites();
    if (!favorites.contains(coinId)) {
      favorites.add(coinId);
      await _prefs.setStringList(_favoritesKey, favorites);
    }
  }

  /// Removes a [coinId] from the favorites list if it exists.
  Future<void> removeFavorite(String coinId) async {
    final favorites = getFavorites();
    if (favorites.contains(coinId)) {
      favorites.remove(coinId);
      await _prefs.setStringList(_favoritesKey, favorites);
    }
  }

  /// Toggles the favorite status of a [coinId].
  /// 
  /// Adds the ID if it's not present, or removes it if it is.
  Future<void> toggleFavorite(String coinId) async {
    final favorites = getFavorites();
    if (favorites.contains(coinId)) {
      favorites.remove(coinId);
    } else {
      favorites.add(coinId);
    }
    await _prefs.setStringList(_favoritesKey, favorites);
  }
  
  /// Checks if a specific [coinId] is currently marked as a favorite.
  bool isFavorite(String coinId) {
    return getFavorites().contains(coinId);
  }
}
