import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import '../../providers/local_providers.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _offerBiometrics = false;
  bool _biometricsEnabled = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isAvailable = await _localAuth.isDeviceSupported();
      if (mounted && canCheck && isAvailable) {
        setState(() => _offerBiometrics = true);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    HapticFeedback.lightImpact();
    final current = _isConfirming ? _confirmPin : _pin;
    if (current.length >= 6) return;

    setState(() {
      if (_isConfirming) {
        _confirmPin += key;
      } else {
        _pin += key;
      }
      _hasError = false;
    });

    if ((_isConfirming ? _confirmPin : _pin).length == 6) {
      _handlePinComplete();
    }
  }

  void _onDelete() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  Future<void> _handlePinComplete() async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (!_isConfirming) {
      setState(() => _isConfirming = true);
    } else {
      if (_pin == _confirmPin) {
        await ref.read(authNotifierProvider.notifier).setupPin(_pin);
        if (_biometricsEnabled) {
          await ref.read(authNotifierProvider.notifier).enableBiometrics();
        }
        await ref
            .read(settingsNotifierProvider.notifier)
            .setSetupComplete(true);
        if (mounted) context.go('/home/dashboard');
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'PINs do not match. Try again.';
          _confirmPin = '';
        });
        _shakeController.forward(from: 0);
        HapticFeedback.vibrate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = _isConfirming ? _confirmPin : _pin;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Header
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  key: ValueKey(_isConfirming),
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF9B72CF).withOpacity(0.3),
                            const Color(0xFF6750A4).withOpacity(0.3),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFF9B72CF).withOpacity(0.5),
                        ),
                      ),
                      child: Icon(
                        _isConfirming
                            ? Icons.verified_user_rounded
                            : Icons.lock_rounded,
                        color: const Color(0xFF9B72CF),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isConfirming ? 'Confirm your PIN' : 'Set a 6-digit PIN',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isConfirming
                          ? 'Re-enter your PIN to confirm'
                          : 'This PIN protects your financial data',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // PIN dots
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(
                    _hasError
                        ? 10 *
                            Math.sin(_shakeAnimation.value * Math.pi * 4)
                        : 0,
                    0,
                  ),
                  child: child,
                ),
                child: _GlassPinDots(
                  length: 6,
                  filled: currentPin.length,
                  hasError: _hasError,
                ),
              ),
              if (_hasError) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Color(0xFFEF5350),
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 48),
              // Numpad
              _NumPad(
                onKey: _onKeyPress,
                onDelete: _onDelete,
                onBiometric: _offerBiometrics ? null : null,
              ),
              const SizedBox(height: 32),
              // Biometrics option
              if (_offerBiometrics && !_isConfirming)
                GestureDetector(
                  onTap: () =>
                      setState(() => _biometricsEnabled = !_biometricsEnabled),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _biometricsEnabled
                            ? const Color(0xFF9B72CF)
                            : Colors.white.withOpacity(0.1),
                      ),
                      color: _biometricsEnabled
                          ? const Color(0xFF9B72CF).withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fingerprint_rounded,
                          color: _biometricsEnabled
                              ? const Color(0xFF9B72CF)
                              : Colors.white.withOpacity(0.4),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Enable biometric unlock',
                          style: TextStyle(
                            color: _biometricsEnabled
                                ? const Color(0xFF9B72CF)
                                : Colors.white.withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (_biometricsEnabled)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF9B72CF),
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: avoid_classes_with_only_static_members
class Math {
  static double sin(double x) => x - x * x * x / 6;
  static double get pi => 3.141592653589793;
}

class _GlassPinDots extends StatelessWidget {
  final int length;
  final int filled;
  final bool hasError;

  const _GlassPinDots({
    required this.length,
    required this.filled,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final isFilled = i < filled;
        return Container(
          width: 52,
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? hasError
                    ? const Color(0xFFEF5350).withOpacity(0.2)
                    : const Color(0xFF9B72CF).withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            border: Border.all(
              color: isFilled
                  ? hasError
                      ? const Color(0xFFEF5350)
                      : const Color(0xFF9B72CF)
                  : Colors.white.withOpacity(0.15),
              width: 2,
            ),
            boxShadow: isFilled && !hasError
                ? [
                    BoxShadow(
                      color: const Color(0xFF6750A4).withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: isFilled
              ? Center(
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasError
                          ? const Color(0xFFEF5350)
                          : const Color(0xFF9B72CF),
                    ),
                  ),
                )
              : null,
        );
      }),
    );
  }
}

class _NumPad extends StatelessWidget {
  final void Function(String) onKey;
  final VoidCallback onDelete;
  final VoidCallback? onBiometric;

  const _NumPad({
    required this.onKey,
    required this.onDelete,
    this.onBiometric,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', 'del'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row
                .map((key) => _NumKey(
                      label: key,
                      onTap: key == 'del'
                          ? onDelete
                          : key.isEmpty
                              ? onBiometric
                              : () => onKey(key),
                    ))
                .toList(),
          ),
      ],
    );
  }
}

class _NumKey extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _NumKey({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (label == 'del') {
      child = const Icon(
        Icons.backspace_outlined,
        color: Colors.white70,
        size: 24,
      );
    } else if (label.isEmpty) {
      child = const Icon(
        Icons.fingerprint_rounded,
        color: Colors.white30,
        size: 28,
      );
    } else {
      child = Text(
        label,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: label.isEmpty
              ? Colors.transparent
              : Colors.white.withOpacity(0.05),
          border: label.isEmpty || label == 'del'
              ? null
              : Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
        ),
        child: Center(child: child),
      ),
    );
  }
}
