import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Premium stat card for dashboard metrics.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final double? trendPercent;
  final bool trendPositiveIsGood;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.trendPercent,
    this.trendPositiveIsGood = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
    final hasTrend = trendPercent != null;
    final isPositive = (trendPercent ?? 0) >= 0;
    final trendGood = trendPositiveIsGood ? isPositive : !isPositive;
    final trendColor = trendGood ? AppColors.income : AppColors.expense;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              if (hasTrend)
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: trendColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${trendPercent!.abs().toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: trendColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Account summary card with gradient accent.
class AccountCard extends StatelessWidget {
  final String name;
  final String type;
  final double balance;
  final String currencyCode;
  final String? bankName;
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    required this.name,
    required this.type,
    required this.balance,
    this.currencyCode = 'INR',
    this.bankName,
    this.onTap,
  });

  Color get _accentColor {
    switch (type) {
      case 'asset':
        return AppColors.primary;
      case 'cash':
        return AppColors.secondary;
      case 'liability':
        return AppColors.expense;
      case 'revenue':
        return AppColors.income;
      default:
        return AppColors.primary;
    }
  }

  IconData get _icon {
    switch (type) {
      case 'asset':
        return Icons.account_balance_rounded;
      case 'cash':
        return Icons.payments_rounded;
      case 'liability':
        return Icons.credit_card_rounded;
      case 'revenue':
        return Icons.trending_up_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  String get _formattedBalance {
    final abs = balance.abs();
    if (currencyCode == 'INR') {
      if (abs >= 10000000) return '₹${(abs / 10000000).toStringAsFixed(2)}Cr';
      if (abs >= 100000) return '₹${(abs / 100000).toStringAsFixed(2)}L';
      if (abs >= 1000) return '₹${(abs / 1000).toStringAsFixed(1)}K';
      return '₹${abs.toStringAsFixed(2)}';
    }
    return '$currencyCode ${abs.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(_icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  if (bankName != null)
                    Text(
                      bankName!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  balance < 0 ? '-$_formattedBalance' : _formattedBalance,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: balance < 0 ? AppColors.expense : AppColors.darkTextPrimary,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: accent,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: AppColors.darkTextSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

/// Animated circular progress budget card.
class BudgetProgressCard extends StatelessWidget {
  final String name;
  final String period;
  final double limit;
  final double spent;
  final VoidCallback? onTap;

  const BudgetProgressCard({
    super.key,
    required this.name,
    required this.period,
    required this.limit,
    required this.spent,
    this.onTap,
  });

  double get percentage => limit > 0 ? (spent / limit).clamp(0, 1) : 0;

  Color get _progressColor {
    if (percentage >= 1.0) return AppColors.expense;
    if (percentage >= 0.8) return AppColors.warning;
    return AppColors.income;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (limit - spent).clamp(0, double.infinity);
    final color = _progressColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 5,
                    backgroundColor: AppColors.darkElevated,
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Text(
                      '${(percentage * 100).toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    period.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.darkTextSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${spent.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  'of ₹${limit.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state widget with icon, title, subtitle, and optional action.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.primary.withOpacity(0.7)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.darkTextSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(actionLabel!, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
