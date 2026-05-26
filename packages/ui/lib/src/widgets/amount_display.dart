import 'package:flutter/material.dart';
import 'package:neo_shared/neo_shared.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Animated amount display widget with count-up animation and color coding
class AmountDisplay extends StatefulWidget {
  final double amount;
  final String currencyCode;
  final bool isExpense;
  final bool isIncome;
  final bool compact;
  final bool animate;
  final TextStyle? style;
  final bool showSign;
  final Color? color;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.currencyCode = 'INR',
    this.isExpense = false,
    this.isIncome = false,
    this.compact = false,
    this.animate = true,
    this.style,
    this.showSign = false,
    this.color,
  });

  @override
  State<AmountDisplay> createState() => _AmountDisplayState();
}

class _AmountDisplayState extends State<AmountDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _displayAmount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _setupAnimation();
    if (widget.animate) {
      _controller.forward();
    } else {
      _displayAmount = widget.amount;
    }
  }

  void _setupAnimation() {
    _animation = Tween<double>(
      begin: 0,
      end: widget.amount,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() => _displayAmount = _animation.value);
      });
  }

  @override
  void didUpdateWidget(AmountDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _animation = Tween<double>(
        begin: _displayAmount,
        end: widget.amount,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      )..addListener(() {
          setState(() => _displayAmount = _animation.value);
        });
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _amountColor {
    if (widget.color != null) return widget.color!;
    if (widget.isIncome) return AppColors.income;
    if (widget.isExpense) return AppColors.expense;
    return AppColors.transfer;
  }

  String get _formattedAmount {
    final amt = widget.animate ? _displayAmount : widget.amount;
    if (widget.compact) {
      return CurrencyFormatter.formatCompact(amt, widget.currencyCode);
    }
    return CurrencyFormatter.formatAmount(amt, widget.currencyCode);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? AppTypography.amountLarge;
    String display = _formattedAmount;
    if (widget.showSign && widget.amount > 0) display = '+$display';
    if (widget.showSign && widget.amount < 0 && !display.startsWith('-')) {
      display = '-$display';
    }

    return Text(
      display,
      style: style.copyWith(color: _amountColor),
    );
  }
}
