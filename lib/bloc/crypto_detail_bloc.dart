import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/market_chart.dart';
import '../models/coin_detail.dart';
import '../services/crypto_service.dart';
import '../api/exceptions.dart';

abstract class CryptoDetailState {}
class CryptoDetailInitial extends CryptoDetailState {}
class CryptoDetailLoading extends CryptoDetailState {}
class CryptoDetailLoaded extends CryptoDetailState {
  final MarketChart chart;
  final CoinDetail detail;
  CryptoDetailLoaded(this.chart, this.detail);
}
class CryptoDetailError extends CryptoDetailState {
  final String message;
  final bool isRateLimit;
  CryptoDetailError(this.message, {this.isRateLimit = false});
}

abstract class CryptoDetailEvent {}
class FetchCryptoDetail extends CryptoDetailEvent {
  final String id;
  FetchCryptoDetail(this.id);
}

/// [CryptoDetailBloc] is responsible for managing the state of crypto detail screens 
/// 
/// It handles loading, displaying, and error states for detailed coin information 
/// and market charts, including specific handling for rate limit exceptions
class CryptoDetailBloc extends Bloc<CryptoDetailEvent, CryptoDetailState> {
  final CryptoService _cryptoService;

  /// Creates a new [CryptoDetailBloc]
  /// Requires a [CryptoService] instance to fetch coin data
  CryptoDetailBloc(this._cryptoService) : super(CryptoDetailInitial()) {
    on<FetchCryptoDetail>((event, emit) async {
      emit(CryptoDetailLoading());
      try {
        final chartFuture = _cryptoService.getMarketChart(event.id);
        final detailFuture = _cryptoService.getCoinDetail(event.id);
        
        final chart = await chartFuture;
        final detail = await detailFuture;

        emit(CryptoDetailLoaded(chart, detail));
      } on RateLimitException catch (e) {
        emit(CryptoDetailError(e.message, isRateLimit: true));
      } catch (e) {
        emit(CryptoDetailError(e.toString()));
      }
    });
  }
}
