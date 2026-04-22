import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_tracker_lite/l10n/app_localizations.dart';
import '../bloc/crypto_list_bloc.dart';
import '../widgets/coin_list_tile.dart';
import '../widgets/side_menu_drawer.dart';
import '../widgets/error_state_widget.dart';
import '../theme/app_colors.dart';

class HomePage extends StatelessWidget {
  final dynamic cacheManager;
  const HomePage({super.key, this.cacheManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle, style: const TextStyle(fontWeight: FontWeight.w400)),
        centerTitle: true,
      ),
      drawer: const SideMenuDrawer(),
      body: BlocBuilder<CryptoListBloc, CryptoListState>(
        builder: (context, state) {
          if (state is CryptoListLoading || state is CryptoListInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          } else if (state is CryptoListError) {
            if (state.isRateLimit) {
              return ErrorStateWidget(
                onRetry: () => context.read<CryptoListBloc>().add(FetchCryptoList()),
              );
            }
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
          } else if (state is CryptoListLoaded) {
            return Column(
              children: [
                if (state.isRateLimitExceeded)
                  Container(
                    color: AppColors.warning,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.rateLimitBanner,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            context.read<CryptoListBloc>().add(DismissRateLimitWarning());
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
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
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
