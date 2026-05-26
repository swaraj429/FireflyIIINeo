import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/accounts_provider.dart';
import '../../widgets/glass_card.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _typeController;

  String _type = 'expense';
  String _amountStr = '0';
  DateTime _date = DateTime.now();
  String? _selectedAccountId;
  String? _selectedToAccountId;
  String? _selectedCategoryId;
  String _merchant = '';
  String _description = '';
  List<String> _tags = [];
  String _notes = '';
  bool _isSaving = false;

  final _merchantController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  final List<_CategoryItem> _categories = [
    _CategoryItem('food', '🍔', 'Food', 0xFFFF7043),
    _CategoryItem('transport', '🚗', 'Transport', 0xFF42A5F5),
    _CategoryItem('shopping', '🛍️', 'Shopping', 0xFFAB47BC),
    _CategoryItem('bills', '💡', 'Bills', 0xFFFFCA28),
    _CategoryItem('health', '💊', 'Health', 0xFF66BB6A),
    _CategoryItem('entertainment', '🎬', 'Entertainment', 0xFFEF5350),
    _CategoryItem('education', '📚', 'Education', 0xFF29B6F6),
    _CategoryItem('salary', '💰', 'Salary', 0xFF4CAF50),
    _CategoryItem('rent', '🏠', 'Rent', 0xFFFF8A65),
    _CategoryItem('gym', '💪', 'Gym', 0xFFEC407A),
    _CategoryItem('travel', '✈️', 'Travel', 0xFF26C6DA),
    _CategoryItem('other', '📦', 'Other', 0xFF78909C),
  ];

  @override
  void initState() {
    super.initState();
    _typeController = TabController(length: 3, vsync: this);
    _typeController.addListener(() {
      if (!_typeController.indexIsChanging) {
        setState(() {
          _type = ['expense', 'income', 'transfer'][_typeController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _typeController.dispose();
    _merchantController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _appendDigit(String d) {
    setState(() {
      if (_amountStr == '0') {
        _amountStr = d;
      } else {
        if (d == '.' && _amountStr.contains('.')) return;
        final parts = _amountStr.split('.');
        if (parts.length == 2 && parts[1].length >= 2) return;
        _amountStr += d;
      }
    });
  }

  void _deleteDigit() {
    setState(() {
      if (_amountStr.length <= 1) {
        _amountStr = '0';
      } else {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      }
    });
  }

  double get _amount => double.tryParse(_amountStr) ?? 0;

  Color get _typeColor {
    switch (_type) {
      case 'income':
        return const Color(0xFF4CAF50);
      case 'transfer':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFFEF5350);
    }
  }

  Future<void> _save() async {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ref.read(transactionsPaginationProvider.notifier).addTransaction(
            type: _type,
            amount: _amount,
            date: _date,
            accountId: _selectedAccountId ?? 'default',
            toAccountId: _selectedToAccountId,
            categoryId: _selectedCategoryId,
            merchant: _merchantController.text,
            description: _descriptionController.text,
            tags: _tags,
            notes: _notesController.text,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0D0D12),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white70),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'New Transaction',
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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Type selector
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _typeController,
                    indicator: BoxDecoration(
                      color: _typeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _typeColor.withOpacity(0.5)),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: _typeColor,
                    unselectedLabelColor: Colors.white38,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(text: 'Expense'),
                      Tab(text: 'Income'),
                      Tab(text: 'Transfer'),
                    ],
                  ),
                ),
                const Gap(24),
                // Amount display
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _typeColor.withOpacity(0.15),
                        _typeColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: _typeColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _type == 'expense' ? 'Amount to Pay' : 'Amount Received',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Gap(8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '₹',
                              style: TextStyle(
                                fontSize: 28,
                                color: _typeColor.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Gap(4),
                          Text(
                            _amountStr,
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                              color: _typeColor,
                              letterSpacing: -2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                // Number pad
                _NumericPad(
                  onDigit: _appendDigit,
                  onDelete: _deleteDigit,
                  accentColor: _typeColor,
                ),
                const Gap(20),
                // Date picker
                GestureDetector(
                  onTap: _pickDate,
                  child: GlassCard(
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            color: Colors.white.withOpacity(0.5), size: 20),
                        const Gap(12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date & Time',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                            Text(
                              DateFormat('EEE, d MMM yyyy — h:mm a')
                                  .format(_date),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded,
                            color: Colors.white.withOpacity(0.3)),
                      ],
                    ),
                  ),
                ),
                const Gap(12),
                // Account selector
                _AccountSelector(
                  selectedId: _selectedAccountId,
                  onSelected: (id) =>
                      setState(() => _selectedAccountId = id),
                  label: 'Account',
                ),
                if (_type == 'transfer') ...[
                  const Gap(12),
                  _AccountSelector(
                    selectedId: _selectedToAccountId,
                    onSelected: (id) =>
                        setState(() => _selectedToAccountId = id),
                    label: 'To Account',
                  ),
                ],
                const Gap(20),
                // Category grid
                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const Gap(10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final isSelected = _selectedCategoryId == cat.id;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategoryId = cat.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(cat.color).withOpacity(0.2)
                              : const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? Color(cat.color)
                                : Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat.emoji,
                                style: const TextStyle(fontSize: 26)),
                            const Gap(4),
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? Color(cat.color)
                                    : Colors.white.withOpacity(0.5),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Gap(20),
                // Merchant
                _FormField(
                  controller: _merchantController,
                  label: 'Merchant / Payee',
                  hint: 'e.g., Swiggy, Zomato...',
                  icon: Icons.store_rounded,
                ),
                const Gap(12),
                // Description
                _FormField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'What was this for?',
                  icon: Icons.notes_rounded,
                ),
                const Gap(12),
                // Tags
                _TagsField(
                  tags: _tags,
                  onChanged: (tags) => setState(() => _tags = tags),
                ),
                const Gap(12),
                // Notes
                _FormField(
                  controller: _notesController,
                  label: 'Notes',
                  hint: 'Additional notes...',
                  icon: Icons.sticky_note_2_outlined,
                  maxLines: 3,
                ),
                const Gap(80),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: _typeColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save Transaction',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF9B72CF),
            surface: Color(0xFF1A1A2E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_date),
        builder: (context, child) => Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF9B72CF),
              surface: Color(0xFF1A1A2E),
            ),
          ),
          child: child!,
        ),
      );
      if (timePicked != null) {
        setState(() {
          _date = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        });
      }
    }
  }
}

class _NumericPad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onDelete;
  final Color accentColor;

  const _NumericPad({
    required this.onDigit,
    required this.onDelete,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['.', '0', '⌫'],
    ];

    return Column(
      children: rows
          .map(
            (row) => Row(
              children: row.map((key) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (key == '⌫') {
                        onDelete();
                      } else {
                        onDigit(key);
                      }
                    },
                    child: Container(
                      height: 60,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: key == '⌫'
                            ? accentColor.withOpacity(0.1)
                            : const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: Center(
                        child: key == '⌫'
                            ? Icon(Icons.backspace_outlined,
                                color: accentColor, size: 20)
                            : Text(
                                key,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
          .toList(),
    );
  }
}

class _AccountSelector extends ConsumerWidget {
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final String label;

  const _AccountSelector({
    required this.selectedId,
    required this.onSelected,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsListProvider);

    return accountsAsync.when(
      loading: () => const SizedBox(height: 56),
      error: (_, __) => const SizedBox(),
      data: (accounts) => GestureDetector(
        onTap: () => _showAccountPicker(context, accounts),
        child: GlassCard(
          child: Row(
            children: [
              Icon(Icons.credit_card_rounded,
                  color: Colors.white.withOpacity(0.4), size: 20),
              const Gap(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                  Text(
                    accounts
                            .firstWhere(
                              (a) => a.id == selectedId,
                              orElse: () => accounts.isNotEmpty
                                  ? accounts.first
                                  : const AccountItem(
                                      id: '',
                                      name: 'Select account',
                                      type: '',
                                      balance: 0),
                            )
                            .name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountPicker(BuildContext context, List<AccountItem> accounts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select $label',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(16),
            ...accounts.map(
              (a) => ListTile(
                onTap: () {
                  onSelected(a.id);
                  Navigator.pop(ctx);
                },
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF9B72CF).withOpacity(0.2),
                  ),
                  child: const Icon(Icons.account_balance_rounded,
                      color: Color(0xFF9B72CF), size: 20),
                ),
                title: Text(a.name,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: Text(
                  '₹${NumberFormat('#,##,###').format(a.balance)}',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
                trailing: a.id == selectedId
                    ? const Icon(Icons.check_rounded, color: Color(0xFF9B72CF))
                    : null,
              ),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.3), size: 20),
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF9B72CF)),
        ),
      ),
    );
  }
}

class _TagsField extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  const _TagsField({required this.tags, required this.onChanged});

  @override
  State<_TagsField> createState() => _TagsFieldState();
}

class _TagsFieldState extends State<_TagsField> {
  final _controller = TextEditingController();

  void _addTag(String tag) {
    tag = tag.trim();
    if (tag.isNotEmpty && !widget.tags.contains(tag)) {
      widget.onChanged([...widget.tags, tag]);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onSubmitted: _addTag,
          decoration: InputDecoration(
            labelText: 'Tags',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            hintText: 'Add tag and press enter',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            prefixIcon: Icon(Icons.label_outline_rounded,
                color: Colors.white.withOpacity(0.3), size: 20),
            filled: true,
            fillColor: const Color(0xFF1A1A2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF9B72CF)),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_rounded, color: Color(0xFF9B72CF)),
              onPressed: () => _addTag(_controller.text),
            ),
          ),
        ),
        if (widget.tags.isNotEmpty) ...[
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.tags
                .map(
                  (tag) => Chip(
                    label: Text(tag,
                        style: const TextStyle(
                            color: Color(0xFF9B72CF), fontSize: 12)),
                    deleteIcon:
                        const Icon(Icons.close_rounded, size: 14),
                    deleteIconColor: const Color(0xFF9B72CF),
                    onDeleted: () => widget.onChanged(
                      widget.tags.where((t) => t != tag).toList(),
                    ),
                    backgroundColor:
                        const Color(0xFF6750A4).withOpacity(0.15),
                    side: BorderSide(
                      color: const Color(0xFF9B72CF).withOpacity(0.3),
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _CategoryItem {
  final String id;
  final String emoji;
  final String name;
  final int color;

  const _CategoryItem(this.id, this.emoji, this.name, this.color);
}
