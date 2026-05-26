import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_core/neo_core.dart';
import 'package:neo_ui/neo_ui.dart';
import 'package:collection/collection.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Accounts',
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            color: AppColors.darkTextPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            color: AppColors.primary,
            onPressed: () {
              // TODO: Open add account sheet
            },
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const AccountCardShimmer(),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return EmptyState(
              icon: Icons.account_balance_wallet_rounded,
              title: 'No accounts yet',
              subtitle: 'Add your first bank account or wallet to start tracking.',
              actionLabel: 'Add Account',
              onAction: () {},
            );
          }

          // Group by type (enum AccountType => string representation handling)
          final grouped = groupBy(accounts, (a) => a.type.name);

          return RefreshIndicator(
            onRefresh: () => ref.read(accountsProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                if (grouped.containsKey('asset')) ...[
                  _buildSectionHeader('Assets & Banks'),
                  ...grouped['asset']!.map((a) => AccountCard(
                    name: a.name,
                    type: a.type.name,
                    balance: a.currentBalance,
                    currencyCode: a.currencyCode,
                    bankName: a.bankName,
                  )),
                ],
                if (grouped.containsKey('cash')) ...[
                  _buildSectionHeader('Cash Wallets'),
                  ...grouped['cash']!.map((a) => AccountCard(
                    name: a.name,
                    type: a.type.name,
                    balance: a.currentBalance,
                    currencyCode: a.currencyCode,
                  )),
                ],
                if (grouped.containsKey('liability')) ...[
                  _buildSectionHeader('Credit Cards & Loans'),
                  ...grouped['liability']!.map((a) => AccountCard(
                    name: a.name,
                    type: a.type.name,
                    balance: a.currentBalance,
                    currencyCode: a.currencyCode,
                    bankName: a.bankName,
                  )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
