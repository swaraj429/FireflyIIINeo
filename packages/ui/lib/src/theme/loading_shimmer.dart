import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'app_colors.dart';

/// Shimmer loading skeleton widgets for the app.
class LoadingShimmer extends StatelessWidget {
  final Widget child;
  const LoadingShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.darkElevated,
      highlightColor: AppColors.darkBorder,
      child: child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Shimmer skeleton for a transaction list item.
class TransactionListShimmer extends StatelessWidget {
  final int count;
  const TransactionListShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              const ShimmerBox(width: 44, height: 44, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: double.infinity * 0.6, height: 14),
                    const SizedBox(height: 6),
                    const ShimmerBox(width: 80, height: 11),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const ShimmerBox(width: 70, height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for a stat card row.
class StatCardShimmer extends StatelessWidget {
  const StatCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      child: Row(
        children: List.generate(3, (_) => Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Container(
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        )),
      ),
    );
  }
}

/// Shimmer skeleton for account cards.
class AccountCardShimmer extends StatelessWidget {
  const AccountCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      child: Column(
        children: List.generate(3, (_) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        )),
      ),
    );
  }
}
