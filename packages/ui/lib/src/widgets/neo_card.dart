import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Glassmorphism card widget with blur background and gradient border
class NeoCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double blurSigma;
  final Gradient? gradient;
  final bool enableBlur;
  final bool enableGradientBorder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool animate;
  final List<BoxShadow>? shadows;

  const NeoCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppSpacing.radiusLg,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0.8,
    this.blurSigma = 12.0,
    this.gradient,
    this.enableBlur = true,
    this.enableGradientBorder = true,
    this.onTap,
    this.onLongPress,
    this.animate = true,
    this.shadows,
  });

  @override
  State<NeoCard> createState() => _NeoCardState();
}

class _NeoCardState extends State<NeoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.animate && widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.animate && widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.animate && widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? AppColors.glassBackground : AppColors.glassDark);

    final borderColor = widget.borderColor ??
        (isDark ? AppColors.glassBorder : AppColors.glassBorderDark);

    Widget card = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: widget.gradient,
        boxShadow: widget.shadows ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: widget.enableBlur
              ? ImageFilter.blur(
                  sigmaX: widget.blurSigma,
                  sigmaY: widget.blurSigma,
                )
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            decoration: BoxDecoration(
              color: widget.gradient == null ? bgColor : null,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.enableGradientBorder
                  ? Border.all(color: borderColor, width: widget.borderWidth)
                  : null,
            ),
            padding: widget.padding ??
                const EdgeInsets.all(AppSpacing.cardPadding),
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.onTap != null || widget.onLongPress != null) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.animate ? _scaleAnimation.value : 1.0,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: card,
        ),
      );
    }

    return card;
  }
}
