import '../api/api_client.dart';
import '../models/coin.dart';
import '../models/market_chart.dart';
import '../models/coin_detail.dart';

/// [CryptoService] acts as a high-level domain service for fetching cryptocurrency data.
/// 
/// It abstracts the [ApiClient] logic and maps raw JSON responses into 
/// strongly-typed model instances like [Coin], [MarketChart], and [CoinDetail].
class CryptoService {
  final ApiClient _apiClient;

  /// Creates a new [CryptoService] instance with a required [ApiClient].
  CryptoService(this._apiClient);

  /// Fetches a list of top cryptocurrency markets.
  /// 
  /// The [currency] parameter defaults to 'usd'.
  /// Returns a list of [Coin] objects representing the market data.
  Future<List<Coin>> getMarkets({String currency = 'usd'}) async {
    final data = await _apiClient.get(
      '/coins/markets?vs_currency=$currency&order=market_cap_desc&per_page=100&page=1&sparkline=false',
    );
    
    final List<dynamic> listData = data as List<dynamic>;
    return listData.map((e) => Coin.fromJson(e)).toList();
  }

  /// Fetches historical market chart data for a specific coin.
  /// 
  /// [id] is the unique identifier of the coin (e.g., 'bitcoin').
  /// [currency] defaults to 'usd' and [days] defaults to 7.
  Future<MarketChart> getMarketChart(String id, {String currency = 'usd', int days = 7}) async {
    final data = await _apiClient.get(
      '/coins/$id/market_chart?vs_currency=$currency&days=$days',
    );
    
    return MarketChart.fromJson(data);
  }

  /// Fetches comprehensive details for a specific coin.
  /// 
  /// [id] is the unique identifier of the coin.
  /// Filters unnecessary data categories (community, developer, etc.) for performance.
  Future<CoinDetail> getCoinDetail(String id) async {
    final data = await _apiClient.get(
      '/coins/$id?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false',
    );
    
    return CoinDetail.fromJson(data);
  }
}
