import 'package:flutter/material.dart';
import 'package:crypto_tracker_lite/l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class ErrorStateWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorStateWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.danger, width: 4),
            ),
            child: const Icon(Icons.priority_high, color: AppColors.danger, size: 50),
          ),
          const SizedBox(height: 30),
          Text(
            l10n.errorTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              l10n.errorRateLimitBody,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 30),
          InkWell(
            onTap: onRetry,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: AppColors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.retry, style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
