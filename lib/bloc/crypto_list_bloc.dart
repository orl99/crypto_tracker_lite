import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/coin.dart';
import '../services/crypto_service.dart';
import '../api/exceptions.dart';

abstract class CryptoListState {}
class CryptoListInitial extends CryptoListState {}
class CryptoListLoading extends CryptoListState {}
class CryptoListLoaded extends CryptoListState {
  final List<Coin> coins;
  CryptoListLoaded(this.coins);
}
class CryptoListError extends CryptoListState {
  final String message;
  final bool isRateLimit;
  CryptoListError(this.message, {this.isRateLimit = false});
}

abstract class CryptoListEvent {}
class FetchCryptoList extends CryptoListEvent {}

class CryptoListBloc extends Bloc<CryptoListEvent, CryptoListState> {
  final CryptoService _cryptoService;

  CryptoListBloc(this._cryptoService) : super(CryptoListInitial()) {
    on<FetchCryptoList>((event, emit) async {
      emit(CryptoListLoading());
      try {
        final coins = await _cryptoService.getMarkets();
        emit(CryptoListLoaded(coins));
      } on RateLimitException catch (e) {
        emit(CryptoListError(e.message, isRateLimit: true));
      } catch (e) {
        emit(CryptoListError(e.toString()));
      }
    });
  }
}
