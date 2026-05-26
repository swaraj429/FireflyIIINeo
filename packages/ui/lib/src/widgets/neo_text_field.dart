import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

/// Custom text field with animated floating label, error state, icons, password toggle
class NeoTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final bool showPasswordToggle;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool autofocus;
  final FocusNode? focusNode;
  final List<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefix;
  final Widget? suffix;

  const NeoTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
    this.focusNode,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.prefix,
    this.suffix,
  });

  @override
  State<NeoTextField> createState() => _NeoTextFieldState();
}

class _NeoTextFieldState extends State<NeoTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final activeColor = hasError ? AppColors.error : AppColors.primary;
    final inactiveColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final borderColor = _hasFocus ? activeColor : inactiveColor;

    Widget? suffixWidget;
    if (widget.showPasswordToggle) {
      suffixWidget = GestureDetector(
        onTap: () => setState(() => _obscureText = !_obscureText),
        child: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: AppSpacing.iconMd,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      );
    } else if (widget.suffixIcon != null) {
      suffixWidget = GestureDetector(
        onTap: widget.onSuffixIconTap,
        child: Icon(
          widget.suffixIcon,
          size: AppSpacing.iconMd,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      );
    } else if (widget.suffix != null) {
      suffixWidget = widget.suffix;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: borderColor,
              width: _hasFocus ? 1.5 : 0.8,
            ),
            color: widget.enabled
                ? (isDark ? AppColors.darkElevated : AppColors.lightElevated)
                : (isDark
                    ? AppColors.darkElevated.withOpacity(0.5)
                    : AppColors.lightElevated.withOpacity(0.5)),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            enabled: widget.enabled,
            maxLines: _obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            autofocus: widget.autofocus,
            autofillHints: widget.autofillHints,
            textCapitalization: widget.textCapitalization,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              labelStyle: AppTypography.bodyMedium.copyWith(
                color: _hasFocus
                    ? activeColor
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: widget.contentPadding ??
                  EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: widget.maxLines != null && widget.maxLines! > 1
                        ? AppSpacing.md
                        : AppSpacing.smMd,
                  ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: AppSpacing.iconMd,
                      color: _hasFocus
                          ? activeColor
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    )
                  : widget.prefix != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 12, right: 4),
                          child: widget.prefix,
                        )
                      : null,
              suffixIcon: suffixWidget != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: suffixWidget,
                    )
                  : null,
              counterText: '',
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 12,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              widget.helperText!,
              style: AppTypography.labelSmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
