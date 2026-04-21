import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/coin.dart';
import '../services/crypto_service.dart';
import '../api/exceptions.dart';

abstract class CryptoListState {}
class CryptoListInitial extends CryptoListState {}
class CryptoListLoading extends CryptoListState {}
class CryptoListLoaded extends CryptoListState {
  final List<Coin> coins;
  final bool isRateLimitExceeded;
  CryptoListLoaded(this.coins, {this.isRateLimitExceeded = false});
}
class CryptoListError extends CryptoListState {
  final String message;
  final bool isRateLimit;
  CryptoListError(this.message, {this.isRateLimit = false});
}

abstract class CryptoListEvent {}
class FetchCryptoList extends CryptoListEvent {}
class DismissRateLimitWarning extends CryptoListEvent {}

class CryptoListBloc extends Bloc<CryptoListEvent, CryptoListState> {
  final CryptoService _cryptoService;

  CryptoListBloc(this._cryptoService) : super(CryptoListInitial()) {
    on<FetchCryptoList>((event, emit) async {
      List<Coin>? currentCoins;
      if (state is CryptoListLoaded) {
        currentCoins = (state as CryptoListLoaded).coins;
      }

      if (currentCoins == null) {
        emit(CryptoListLoading());
      }
      
      try {
        final coins = await _cryptoService.getMarkets();
        emit(CryptoListLoaded(coins));
      } on RateLimitException catch (e) {
        if (currentCoins != null && currentCoins.isNotEmpty) {
          emit(CryptoListLoaded(currentCoins, isRateLimitExceeded: true));
        } else {
          emit(CryptoListError(e.message, isRateLimit: true));
        }
      } catch (e) {
        emit(CryptoListError(e.toString()));
      }
    });

    on<DismissRateLimitWarning>((event, emit) {
      if (state is CryptoListLoaded) {
        final currentState = state as CryptoListLoaded;
        emit(CryptoListLoaded(currentState.coins, isRateLimitExceeded: false));
      }
    });
  }
}
