import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/coin.dart';
import '../bloc/crypto_detail_bloc.dart';
import '../bloc/favorites_bloc.dart';
import '../theme/app_colors.dart';

class CryptoDetailPage extends StatefulWidget {
  final Coin coin;

  const CryptoDetailPage({super.key, required this.coin});

  @override
  State<CryptoDetailPage> createState() => _CryptoDetailPageState();
}

class _CryptoDetailPageState extends State<CryptoDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<CryptoDetailBloc>().add(FetchCryptoDetail(widget.coin.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalle', style: TextStyle(fontWeight: FontWeight.w400)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              bool isFav = false;
              if (state is FavoritesLoaded) {
                isFav = state.favoriteIds.contains(widget.coin.id);
              }
              return IconButton(
                icon: Icon(
                  isFav ? Icons.star : Icons.star_border,
                  color: isFav ? AppColors.gold : Colors.grey,
                ),
                onPressed: () {
                  context.read<FavoritesBloc>().add(ToggleFavorite(widget.coin.id));
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.coin.image, 
                  width: 64, 
                  height: 64,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.coin.name,
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.coin.symbol.toUpperCase(),
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Precio actual',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${widget.coin.currentPrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: widget.coin.priceChangePercentage24h >= 0 
                      ? AppColors.success.withValues(alpha: 0.15) 
                      : AppColors.danger.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.coin.priceChangePercentage24h >= 0 ? AppColors.success : AppColors.danger,
                    )
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.coin.priceChangePercentage24h >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: widget.coin.priceChangePercentage24h >= 0 ? AppColors.success : AppColors.danger,
                        size: 20,
                      ),
                      Text(
                        '${(widget.coin.priceChangePercentage24h >= 0 ? '+' : '')}${widget.coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: widget.coin.priceChangePercentage24h >= 0 ? AppColors.success : AppColors.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: _buildStatCard('Máximo 24h', '\$${widget.coin.high24h.toStringAsFixed(2)}', Icons.arrow_outward, AppColors.success)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Mínimo 24h', '\$${widget.coin.low24h.toStringAsFixed(2)}', Icons.call_received, AppColors.danger)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Capitalización', '\$${(widget.coin.marketCap / 1e9).toStringAsFixed(2)}B', Icons.account_balance_wallet, AppColors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Volumen 24h', '\$${(widget.coin.totalVolume / 1e6).toStringAsFixed(2)}M', Icons.swap_horiz, AppColors.warning)),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.gradientStart,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Precio histórico (7 días)',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.coin.priceChangePercentage24h >= 0 ? AppColors.success.withValues(alpha: 0.2) : AppColors.danger.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: widget.coin.priceChangePercentage24h >= 0 ? AppColors.success : AppColors.danger),
                        ),
                        child: Text(
                          '\$${widget.coin.currentPrice.toStringAsFixed(2)}', 
                          style: TextStyle(
                            color: widget.coin.priceChangePercentage24h >= 0 ? AppColors.success : AppColors.danger, 
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 220,
                    child: BlocBuilder<CryptoDetailBloc, CryptoDetailState>(
                      builder: (context, state) {
                        if (state is CryptoDetailLoading || state is CryptoDetailInitial) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                        } else if (state is CryptoDetailError) {
                          if (state.isRateLimit) {
                            return const Center(child: Text('Límite de API alcanzado. Espera unos segundos.', style: TextStyle(color: Colors.red)));
                          }
                          return const Center(child: Text('Error cargando gráfica', style: TextStyle(color: Colors.red)));
                        } else if (state is CryptoDetailLoaded) {
                          return _buildChart(state.chart.prices, widget.coin.priceChangePercentage24h >= 0 ? AppColors.success : AppColors.danger);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Acerca de',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            BlocBuilder<CryptoDetailBloc, CryptoDetailState>(
              builder: (context, state) {
                if (state is CryptoDetailLoaded && state.detail.description.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.gradientStart,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gradientEnd),
                    ),
                    child: Text(
                      state.detail.description,
                      style: const TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gradientStart,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gradientEnd), // subtle border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChart(List<List<double>> prices, Color chartColor) {
    if (prices.isEmpty) return const SizedBox.shrink();

    final spots = prices.map((e) => FlSpot(e[0], e[1])).toList();
    final minX = spots.first.x;
    final maxX = spots.last.x;
    final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY * 0.98,
        maxY: maxY * 1.02,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: AppColors.gradientEnd.withValues(alpha: 0.5), strokeWidth: 1, dashArray: [5, 5]),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                if (value == minY * 0.98 || value == maxY * 1.02) return const SizedBox.shrink();
                return Text('\$${(value/1000).toStringAsFixed(1)}k', style: const TextStyle(color: Colors.grey, fontSize: 10));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == minX) return const Padding(padding: EdgeInsets.only(top: 8), child: Text('Inicio', style: TextStyle(color: Colors.grey, fontSize: 10)));
                if (value == maxX) return const Padding(padding: EdgeInsets.only(top: 8), child: Text('Hoy', style: TextStyle(color: Colors.grey, fontSize: 10)));
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: chartColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [chartColor.withValues(alpha: 0.3), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
