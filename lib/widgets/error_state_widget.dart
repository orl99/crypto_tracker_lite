import 'package:flutter/material.dart';
import 'package:crypto_tracker_lite/l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class ErrorStateWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final String? title;
  final String? message;
  final IconData? icon;
  final bool isCompact;

  const ErrorStateWidget({
    super.key, 
    required this.onRetry,
    this.title,
    this.message,
    this.icon,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    final displayTitle = title ?? l10n.errorTitle;
    final displayMessage = message ?? l10n.errorRateLimitBody;
    final displayIcon = icon ?? Icons.priority_high;

    if (isCompact) {
      return _buildCompact(l10n);
    }

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
            child: Icon(displayIcon, color: AppColors.danger, size: 50),
          ),
          const SizedBox(height: 30),
          Text(
            displayTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 30),
          _buildRetryButton(l10n),
        ],
      ),
    );
  }

  Widget _buildCompact(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon ?? Icons.error_outline, color: AppColors.danger, size: 30),
          const SizedBox(height: 8),
          Text(
            message ?? l10n.errorLoadingChart,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          _buildRetryButton(l10n, compact: true),
        ],
      ),
    );
  }

  Widget _buildRetryButton(AppLocalizations l10n, {bool compact = false}) {
    return InkWell(
      onTap: onRetry,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 30, 
          vertical: compact ? 8 : 12
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(30),
          border: compact ? Border.all(color: AppColors.blue.withValues(alpha: 0.3)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh, color: AppColors.blue, size: compact ? 16 : 20),
            SizedBox(width: compact ? 4 : 8),
            Text(
              l10n.retry, 
              style: TextStyle(
                color: AppColors.blue, 
                fontWeight: FontWeight.w600,
                fontSize: compact ? 12 : 14,
              )
            ),
          ],
        ),
      ),
    );
  }
}
