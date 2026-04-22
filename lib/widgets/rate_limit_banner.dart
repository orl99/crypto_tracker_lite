import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_tracker_lite/l10n/app_localizations.dart';
import '../bloc/crypto_list_bloc.dart';
import '../theme/app_colors.dart';

/// [RateLimitBanner] displays a warning when the API rate limit is reached.
/// 
/// It listens to the [CryptoListBloc] state and shows an orange banner 
/// with a dismiss button. It can be placed at the top of any page.
class RateLimitBanner extends StatelessWidget {
  const RateLimitBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return BlocBuilder<CryptoListBloc, CryptoListState>(
      builder: (context, state) {
        if (state is CryptoListLoaded && state.isRateLimitExceeded) {
          return Container(
            width: double.infinity,
            color: AppColors.warning,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.rateLimitBanner.split('\n').first,
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        l10n.rateLimitBanner.split('\n').last,
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () {
                    context.read<CryptoListBloc>().add(DismissRateLimitWarning());
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
