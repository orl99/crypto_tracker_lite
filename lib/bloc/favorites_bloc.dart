import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/favorites_service.dart';

abstract class FavoritesState {}
class FavoritesLoaded extends FavoritesState {
  final List<String> favoriteIds;
  FavoritesLoaded(this.favoriteIds);
}

abstract class FavoritesEvent {}
class LoadFavorites extends FavoritesEvent {}
class ToggleFavorite extends FavoritesEvent {
  final String coinId;
  ToggleFavorite(this.coinId);
}

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesService _favoritesService;

  FavoritesBloc(this._favoritesService) : super(FavoritesLoaded(const [])) {
    on<LoadFavorites>((event, emit) {
      final favs = _favoritesService.getFavorites();
      emit(FavoritesLoaded(favs));
    });

    on<ToggleFavorite>((event, emit) async {
      await _favoritesService.toggleFavorite(event.coinId);
      final favs = _favoritesService.getFavorites();
      emit(FavoritesLoaded(favs));
    });
  }
}
