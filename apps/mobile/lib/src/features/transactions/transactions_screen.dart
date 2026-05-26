import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neo_core/neo_core.dart';
import 'package:neo_ui/neo_ui.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(transactionFilterProvider.notifier).state = 
      TransactionFilter(search: query.isEmpty ? null : query);
  }

  @override
  Widget build(BuildContext context) {
    // Re-fetch when filter changes
    ref.listen(transactionFilterProvider, (prev, next) {
      if (prev != next) {
        ref.read(transactionsProvider.notifier).applyFilter(next);
      }
    });

    final txAsync = ref.watch(transactionsProvider);
    final smsCount = ref.watch(smsPendingCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Transactions',
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            color: AppColors.darkTextPrimary,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.message_rounded),
                color: AppColors.darkTextPrimary,
                onPressed: () {
                  // TODO: Navigate to SMS pending screen
                },
              ),
              if (smsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.expense,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      smsCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            color: AppColors.darkTextPrimary,
            onPressed: () {
              // TODO: Open filters bottom sheet
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: NeoTextField(
              controller: _searchController,
              label: 'Search',
              hint: 'Search transactions...',
              prefixIcon: Icons.search_rounded,
              onChanged: _onSearch,
            ),
          ),
          Expanded(
            child: txAsync.when(
              loading: () => const TransactionListShimmer(count: 10),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (state) {
                if (state.items.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: 'No transactions found',
                    subtitle: 'Add a new transaction or change your filters.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(transactionsProvider.notifier).applyFilter(ref.read(transactionFilterProvider)),
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final tx = state.items[index];
                      return TransactionTile(
                        transaction: tx,
                        onTap: () {
                          context.push('/transactions/${tx.id}');
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
