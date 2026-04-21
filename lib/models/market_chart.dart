class MarketChart {
  final List<List<double>> prices; // [timestamp, price]

  MarketChart({required this.prices});

  factory MarketChart.fromJson(Map<String, dynamic> json) {
    final pricesData = json['prices'] as List<dynamic>? ?? [];
    List<List<double>> parsedPrices = [];
    
    for (var item in pricesData) {
      if (item is List && item.length >= 2) {
        parsedPrices.add([
          (item[0] as num).toDouble(),
          (item[1] as num).toDouble()
        ]);
      }
    }
    
    return MarketChart(prices: parsedPrices);
  }
}
