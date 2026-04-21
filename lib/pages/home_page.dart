import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/crypto_list_bloc.dart';
import '../widgets/coin_list_tile.dart';
import '../widgets/side_menu_drawer.dart';
import '../widgets/error_state_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CryptoTracker Lite', style: TextStyle(fontWeight: FontWeight.w400)),
        centerTitle: true,
      ),
      drawer: const SideMenuDrawer(),
      body: BlocBuilder<CryptoListBloc, CryptoListState>(
        builder: (context, state) {
          if (state is CryptoListLoading || state is CryptoListInitial) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          } else if (state is CryptoListError) {
            if (state.isRateLimit) {
              return ErrorStateWidget(
                onRetry: () => context.read<CryptoListBloc>().add(FetchCryptoList()),
              );
            }
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
          } else if (state is CryptoListLoaded) {
            return RefreshIndicator(
              color: Colors.amber,
              backgroundColor: const Color(0xFF2C2C35),
              onRefresh: () async {
                context.read<CryptoListBloc>().add(FetchCryptoList());
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.coins.length,
                separatorBuilder: (context, index) => const Divider(color: Color(0xFF2A2A2A), height: 1),
                itemBuilder: (context, index) {
                  return CoinListTile(coin: state.coins[index]);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
