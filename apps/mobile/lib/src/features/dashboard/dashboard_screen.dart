import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neo_core/neo_core.dart';
import 'package:neo_ui/neo_ui.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final txAsync = ref.watch(transactionsProvider);
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning,',
                  style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                ),
                Text(
                  'User', // TODO: Get name from auth provider
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            color: AppColors.darkTextPrimary,
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(dashboardProvider.notifier).refresh();
          ref.read(accountsProvider.notifier).refresh();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: dashboardAsync.when(
                  loading: () => const Column(
                    children: [
                      ShimmerBox(width: double.infinity, height: 120, radius: 24),
                      SizedBox(height: 16),
                      StatCardShimmer(),
                    ],
                  ),
                  error: (e, st) => Center(child: Text('Error: $e')),
                  data: (data) => Column(
                    children: [
                      // Net Worth Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Net Worth',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${data.netWorth.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Income',
                              value: '₹${data.monthlyIncome.toStringAsFixed(0)}',
                              icon: Icons.arrow_downward_rounded,
                              iconColor: AppColors.income,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              label: 'Expenses',
                              value: '₹${data.monthlyExpenses.toStringAsFixed(0)}',
                              icon: Icons.arrow_upward_rounded,
                              iconColor: AppColors.expense,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Recent Transactions Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'See All',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Transactions List
            txAsync.when(
              loading: () => const SliverToBoxAdapter(child: TransactionListShimmer(count: 3)),
              error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
              data: (state) {
                if (state.items.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'No recent transactions',
                          style: TextStyle(color: AppColors.darkTextSecondary),
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tx = state.items[index];
                      // Note: We need a categoryName fallback if not in model directly
                      // This assumes the model has or we use description.
                      return TransactionTile(
                        transaction: tx,
                        onTap: () {
                          context.push('/transactions/${tx.id}');
                        },
                      );
                    },
                    childCount: state.items.length > 5 ? 5 : state.items.length,
                  ),
                );
              },
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding for FAB
          ],
        ),
      ),
    );
  }
}
