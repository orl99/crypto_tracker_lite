import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_tracker_lite/l10n/app_localizations.dart';
import '../bloc/crypto_list_bloc.dart';
import '../widgets/coin_list_tile.dart';
import '../widgets/side_menu_drawer.dart';
import '../widgets/rate_limit_banner.dart';
import '../widgets/error_state_widget.dart';
import '../theme/app_colors.dart';

class HomePage extends StatelessWidget {
  final dynamic cacheManager;
  const HomePage({super.key, this.cacheManager});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.w400)),
        centerTitle: true,
      ),
      drawer: const SideMenuDrawer(),
      body: Column(
        children: [
          const RateLimitBanner(),
          Expanded(
            child: BlocBuilder<CryptoListBloc, CryptoListState>(
        builder: (context, state) {
          if (state is CryptoListLoading || state is CryptoListInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          } else if (state is CryptoListError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<CryptoListBloc>().add(FetchCryptoList()),
            );
                } else if (state is CryptoListLoaded) {
                  return RefreshIndicator(
                    color: AppColors.gold,
                    backgroundColor: AppColors.card,
                    onRefresh: () async {
                      context.read<CryptoListBloc>().add(FetchCryptoList());
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.coins.length,
                      separatorBuilder: (context, index) => const Divider(color: AppColors.gradientStart, height: 1),
                      itemBuilder: (context, index) {
                        return CoinListTile(
                          coin: state.coins[index],
                          cacheManager: cacheManager,
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
