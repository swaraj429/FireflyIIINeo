import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/transactions_provider.dart';
import '../../widgets/glass_card.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String id;

  const TransactionDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionDetailProvider(id));

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: txAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF9B72CF)),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
        data: (tx) => tx == null
            ? const Center(
                child: Text('Transaction not found',
                    style: TextStyle(color: Colors.white54)))
            : _TransactionDetailContent(transaction: tx),
      ),
    );
  }
}

class _TransactionDetailContent extends StatelessWidget {
  final TransactionDetail transaction;

  const _TransactionDetailContent({required this.transaction});

  Color get _typeColor {
    switch (transaction.type) {
      case 'income':
        return const Color(0xFF4CAF50);
      case 'expense':
        return const Color(0xFFEF5350);
      case 'transfer':
        return const Color(0xFF2196F3);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: const Color(0xFF0D0D12),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white70),
              onPressed: () =>
                  context.push('/transactions/${transaction.id}/edit'),
            ),
            IconButton(
              icon:
                  const Icon(Icons.delete_outline_rounded, color: Colors.white70),
              onPressed: () => _confirmDelete(context),
            ),
          ],
          expandedHeight: 240,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _typeColor.withOpacity(0.15),
                    const Color(0xFF0D0D12),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Category icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(transaction.categoryColor ?? 0xFF9B72CF)
                          .withOpacity(0.2),
                      border: Border.all(
                        color: Color(transaction.categoryColor ?? 0xFF9B72CF)
                            .withOpacity(0.4),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        transaction.categoryIcon ?? '💳',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const Gap(12),
                  // Amount (Hero)
                  Hero(
                    tag: 'amount_${transaction.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        '${transaction.type == 'income' ? '+' : '-'}₹${NumberFormat('#,##,###.##').format(transaction.amount)}',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: _typeColor,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                  const Gap(6),
                  Text(
                    transaction.merchant ?? transaction.description,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Gap(24),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              GlassCard(
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.category_rounded,
                      label: 'Category',
                      value: transaction.categoryName ?? 'Uncategorized',
                    ),
                    _Divider(),
                    _DetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: DateFormat('EEEE, d MMMM yyyy').format(
                          DateTime.parse(transaction.date)),
                    ),
                    _Divider(),
                    _DetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Time',
                      value: DateFormat('h:mm a')
                          .format(DateTime.parse(transaction.date)),
                    ),
                    _Divider(),
                    _DetailRow(
                      icon: Icons.credit_card_rounded,
                      label: 'Account',
                      value: transaction.accountName,
                    ),
                    if (transaction.toAccount != null) ...[
                      _Divider(),
                      _DetailRow(
                        icon: Icons.arrow_forward_rounded,
                        label: 'To Account',
                        value: transaction.toAccount!,
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(16),
              if (transaction.description.isNotEmpty) ...[
                GlassCard(
                  child: _DetailRow(
                    icon: Icons.notes_rounded,
                    label: 'Description',
                    value: transaction.description,
                  ),
                ),
                const Gap(16),
              ],
              if (transaction.tags.isNotEmpty) ...[
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.label_outline_rounded,
                              size: 18,
                              color: Colors.white.withOpacity(0.5)),
                          const Gap(10),
                          Text(
                            'Tags',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const Gap(10),
                      Wrap(
                        spacing: 8,
                        children: transaction.tags
                            .map(
                              (tag) => Chip(
                                label: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9B72CF),
                                  ),
                                ),
                                backgroundColor:
                                    const Color(0xFF6750A4).withOpacity(0.15),
                                side: BorderSide(
                                  color: const Color(0xFF9B72CF)
                                      .withOpacity(0.3),
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
              ],
              if (transaction.isFromSms) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF1565C0).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sms_rounded,
                        color: Color(0xFF2196F3),
                        size: 18,
                      ),
                      const Gap(10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Imported from SMS',
                              style: TextStyle(
                                color: Color(0xFF2196F3),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (transaction.smsSender != null)
                              Text(
                                transaction.smsSender!,
                                style: TextStyle(
                                  color:
                                      Colors.white.withOpacity(0.4),
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
              ],
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(
                          '/transactions/${transaction.id}/edit'),
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF9B72CF),
                        side: const BorderSide(color: Color(0xFF9B72CF)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFEF5350).withOpacity(0.2),
                        foregroundColor: const Color(0xFFEF5350),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(40),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete Transaction',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.pop();
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white.withOpacity(0.4)),
          const Gap(12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.white.withOpacity(0.06),
      height: 24,
    );
  }
}
