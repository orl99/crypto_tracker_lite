import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/coin.dart';
import '../bloc/favorites_bloc.dart';
import '../pages/crypto_detail_page.dart';

class CoinListTile extends StatelessWidget {
  final Coin coin;

  const CoinListTile({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    final isPositive = coin.priceChangePercentage24h >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CryptoDetailPage(coin: coin)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: coin.image,
                  width: 48,
                  height: 48,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.name,
                    style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coin.symbol.toUpperCase(),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${coin.currentPrice.toStringAsFixed(coin.currentPrice < 1 ? 6 : 2)}',
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isPositive ? '+' : ''}${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                  style: TextStyle(color: changeColor, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 16),
            BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                bool isFav = false;
                if (state is FavoritesLoaded) {
                  isFav = state.favoriteIds.contains(coin.id);
                }
                return GestureDetector(
                  onTap: () {
                    context.read<FavoritesBloc>().add(ToggleFavorite(coin.id));
                  },
                  child: Icon(
                    isFav ? Icons.star : Icons.star_border,
                    color: isFav ? Colors.amber : Colors.grey,
                    size: 28,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
