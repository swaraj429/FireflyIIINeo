import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

enum NeoButtonSize { small, medium, large }

enum NeoButtonVariant { filled, outlined, ghost }

/// Premium animated button with gradient, loading state, icon, size variants
class NeoButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? child;
  final bool isLoading;
  final bool isDisabled;
  final NeoButtonSize size;
  final NeoButtonVariant variant;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final double? width;
  final double borderRadius;

  const NeoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.child,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = NeoButtonSize.medium,
    this.variant = NeoButtonVariant.filled,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.width,
    this.borderRadius = AppSpacing.radiusMd,
  });

  const NeoButton.small({
    super.key,
    required this.label,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.child,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = NeoButtonVariant.filled,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.width,
    this.borderRadius = AppSpacing.radiusSm,
  }) : size = NeoButtonSize.small;

  const NeoButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.child,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = NeoButtonSize.medium,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.width,
    this.borderRadius = AppSpacing.radiusMd,
  }) : variant = NeoButtonVariant.outlined;

  const NeoButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.child,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = NeoButtonSize.medium,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.width,
    this.borderRadius = AppSpacing.radiusMd,
  }) : variant = NeoButtonVariant.ghost;

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isInteractive =>
      !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

  void _onTapDown(TapDownDetails _) {
    if (_isInteractive) _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (_isInteractive) _controller.reverse();
  }

  void _onTapCancel() {
    if (_isInteractive) _controller.reverse();
  }

  double get _height {
    switch (widget.size) {
      case NeoButtonSize.small:
        return 36;
      case NeoButtonSize.medium:
        return AppSpacing.buttonHeight;
      case NeoButtonSize.large:
        return 58;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case NeoButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 0);
      case NeoButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 0);
      case NeoButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 0);
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case NeoButtonSize.small:
        return AppTypography.labelMedium;
      case NeoButtonSize.medium:
        return AppTypography.labelLarge;
      case NeoButtonSize.large:
        return AppTypography.labelLarge.copyWith(fontSize: 16);
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case NeoButtonSize.small:
        return 16;
      case NeoButtonSize.medium:
        return 18;
      case NeoButtonSize.large:
        return 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color fgColor;
    Color bgColor;
    Gradient? gradient;
    BoxBorder? border;

    switch (widget.variant) {
      case NeoButtonVariant.filled:
        fgColor = widget.foregroundColor ?? Colors.white;
        bgColor = widget.backgroundColor ?? AppColors.primary;
        gradient = widget.gradient ?? AppColors.primaryGradient;
        border = null;
        break;
      case NeoButtonVariant.outlined:
        fgColor = widget.foregroundColor ?? AppColors.primary;
        bgColor = Colors.transparent;
        gradient = null;
        border = Border.all(
          color: widget.backgroundColor ?? AppColors.primary,
          width: 1.5,
        );
        break;
      case NeoButtonVariant.ghost:
        fgColor = widget.foregroundColor ?? AppColors.primary;
        bgColor = widget.backgroundColor ??
            (isDark
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.08));
        gradient = null;
        border = null;
        break;
    }

    if (widget.isDisabled || widget.isLoading) {
      fgColor = fgColor.withOpacity(0.4);
      if (widget.variant == NeoButtonVariant.filled) {
        gradient = null;
        bgColor = bgColor.withOpacity(0.4);
      }
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (widget.prefixIcon != null) ...[
          Icon(widget.prefixIcon, size: _iconSize, color: fgColor),
          const SizedBox(width: 8),
        ],
        widget.child ??
            Text(
              widget.label,
              style: _textStyle.copyWith(color: fgColor),
            ),
        if (widget.suffixIcon != null && !widget.isLoading) ...[
          const SizedBox(width: 8),
          Icon(widget.suffixIcon, size: _iconSize, color: fgColor),
        ],
      ],
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _isInteractive ? widget.onPressed : null,
        child: Container(
          width: widget.width,
          height: _height,
          padding: _padding,
          decoration: BoxDecoration(
            color: gradient == null ? bgColor : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: border,
          ),
          child: Center(child: content),
        ),
      ),
    );
  }
}
