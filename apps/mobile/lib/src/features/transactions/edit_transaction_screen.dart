import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/local_providers.dart';
import '../../widgets/glass_card.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  final String id;

  const EditTransactionScreen({super.key, required this.id});

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends ConsumerState<EditTransactionScreen> {
  final _merchantController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSaving = false;
  bool _isLoaded = false;

  @override
  void dispose() {
    _merchantController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _prefillForm(TransactionDetail tx) {
    if (!_isLoaded) {
      _merchantController.text = tx.merchant ?? '';
      _descriptionController.text = tx.description;
      _amountController.text = tx.amount.toString();
      _isLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D12),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Edit Transaction',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF9B72CF),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF9B72CF),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
        ],
      ),
      body: txAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF9B72CF)),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err',
              style: const TextStyle(color: Colors.red)),
        ),
        data: (tx) {
          if (tx == null) {
            return const Center(
              child: Text('Not found',
                  style: TextStyle(color: Colors.white54)),
            );
          }
          _prefillForm(tx);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount
                TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle:
                        TextStyle(color: Colors.white.withOpacity(0.4)),
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 24,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1A1A2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFF9B72CF)),
                    ),
                  ),
                ),
                const Gap(16),
                TextField(
                  controller: _merchantController,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Merchant / Payee',
                    labelStyle:
                        TextStyle(color: Colors.white.withOpacity(0.4)),
                    prefixIcon: Icon(Icons.store_rounded,
                        color: Colors.white.withOpacity(0.3), size: 20),
                    filled: true,
                    fillColor: const Color(0xFF1A1A2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFF9B72CF)),
                    ),
                  ),
                ),
                const Gap(16),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle:
                        TextStyle(color: Colors.white.withOpacity(0.4)),
                    prefixIcon: Icon(Icons.notes_rounded,
                        color: Colors.white.withOpacity(0.3), size: 20),
                    filled: true,
                    fillColor: const Color(0xFF1A1A2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFF9B72CF)),
                    ),
                  ),
                ),
                const Gap(40),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      context.pop();
    }
  }
}
