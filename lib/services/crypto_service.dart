import '../api/api_client.dart';
import '../models/coin.dart';
import '../models/market_chart.dart';
import '../models/coin_detail.dart';

class CryptoService {
  final ApiClient _apiClient;

  CryptoService(this._apiClient);

  Future<List<Coin>> getMarkets({String currency = 'usd'}) async {
    final data = await _apiClient.get(
      '/coins/markets?vs_currency=$currency&order=market_cap_desc&per_page=100&page=1&sparkline=false',
    );
    
    final List<dynamic> listData = data as List<dynamic>;
    return listData.map((e) => Coin.fromJson(e)).toList();
  }

  Future<MarketChart> getMarketChart(String id, {String currency = 'usd', int days = 7}) async {
    final data = await _apiClient.get(
      '/coins/$id/market_chart?vs_currency=$currency&days=$days',
    );
    
    return MarketChart.fromJson(data);
  }

  Future<CoinDetail> getCoinDetail(String id) async {
    final data = await _apiClient.get(
      '/coins/$id?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false',
    );
    
    return CoinDetail.fromJson(data);
  }
}
