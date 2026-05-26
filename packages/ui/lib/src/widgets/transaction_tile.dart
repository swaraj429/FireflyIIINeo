import 'package:flutter/material.dart';
import 'package:neo_shared/neo_shared.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

/// Beautiful transaction list tile with category icon, amount, date, SMS badge
class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String? accountName;
  final VoidCallback? onTap;
  final bool showAccount;
  final bool animateEntry;
  final int animationIndex;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.accountName,
    this.onTap,
    this.showAccount = true,
    this.animateEntry = false,
    this.animationIndex = 0,
  });

  Color get _typeColor {
    switch (transaction.type) {
      case TransactionType.deposit:
        return AppColors.income;
      case TransactionType.withdrawal:
        return AppColors.expense;
      case TransactionType.transfer:
        return AppColors.transfer;
    }
  }

  String get _amountPrefix {
    switch (transaction.type) {
      case TransactionType.deposit:
        return '+';
      case TransactionType.withdrawal:
        return '-';
      case TransactionType.transfer:
        return '';
    }
  }

  IconData get _defaultIcon {
    switch (transaction.type) {
      case TransactionType.deposit:
        return Icons.arrow_downward_rounded;
      case TransactionType.withdrawal:
        return Icons.arrow_upward_rounded;
      case TransactionType.transfer:
        return Icons.swap_horiz_rounded;
    }
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null) return _typeColor;
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return _typeColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = _parseColor(categoryColor);
    final displayName = transaction.merchantName?.isNotEmpty == true
        ? transaction.merchantName!
        : transaction.description;
    final formattedDate = DateFormatter.formatRelative(transaction.date);
    final formattedAmount = CurrencyFormatter.formatAmount(
      transaction.amount,
      transaction.currencyCode,
    );

    Widget tile = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.smMd,
      ),
      child: Row(
        children: [
          // Category Icon Circle
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: categoryIcon != null && categoryIcon!.isNotEmpty
                  ? Text(
                      categoryIcon!,
                      style: const TextStyle(fontSize: 22),
                    )
                  : Icon(
                      _defaultIcon,
                      color: iconColor,
                      size: 22,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: AppTypography.titleSmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // SMS badge
                    if (transaction.smsSource != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SMS',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.info,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (categoryName != null) ...[
                      Text(
                        categoryName!,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        ' · ',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                    Text(
                      formattedDate,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    if (showAccount && accountName != null) ...[
                      Text(
                        ' · $accountName',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$_amountPrefix$formattedAmount',
                style: AppTypography.amountSmall.copyWith(
                  color: _typeColor,
                ),
              ),
              if (transaction.reconciled)
                Icon(
                  Icons.check_circle_rounded,
                  size: 12,
                  color: AppColors.success.withOpacity(0.7),
                ),
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      tile = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: tile,
      );
    }

    return tile;
  }
}
