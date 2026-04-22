import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/crypto_list_bloc.dart';
import '../bloc/favorites_bloc.dart';
import '../widgets/coin_list_tile.dart';
import '../theme/app_colors.dart';

class FavoritesPage extends StatelessWidget {
  final dynamic cacheManager;
  const FavoritesPage({super.key, this.cacheManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Favoritos ⭐', style: TextStyle(fontWeight: FontWeight.w400)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<CryptoListBloc>().add(FetchCryptoList());
            },
          )
        ],
      ),
      body: BlocBuilder<CryptoListBloc, CryptoListState>(
        builder: (context, cryptoState) {
          if (cryptoState is CryptoListLoading || cryptoState is CryptoListInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          } else if (cryptoState is CryptoListError) {
            return Center(child: Text(cryptoState.message, style: const TextStyle(color: Colors.white)));
          } else if (cryptoState is CryptoListLoaded) {
            return BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, favState) {
                if (favState is FavoritesLoaded) {
                  final favoriteCoins = cryptoState.coins
                      .where((coin) => favState.favoriteIds.contains(coin.id))
                      .toList();

                  if (favoriteCoins.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: favoriteCoins.length,
                    separatorBuilder: (context, index) => const Divider(color: AppColors.gradientStart, height: 1),
                    itemBuilder: (context, index) {
                      return CoinListTile(
                        coin: favoriteCoins[index],
                        cacheManager: cacheManager,
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border, size: 80, color: AppColors.gold.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'Aún no tienes favoritos',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca la estrella en cualquier moneda\npara añadirla aquí',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
