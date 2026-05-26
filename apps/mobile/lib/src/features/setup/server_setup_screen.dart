import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/local_providers.dart';

class ServerSetupScreen extends ConsumerStatefulWidget {
  const ServerSetupScreen({super.key});

  @override
  ConsumerState<ServerSetupScreen> createState() => _ServerSetupScreenState();
}

class _ServerSetupScreenState extends ConsumerState<ServerSetupScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _checkController;
  late Animation<double> _checkScale;

  int _stepIndex = 0;
  bool _isComplete = false;
  bool _hasError = false;
  final _urlController = TextEditingController();
  bool _showManualUrl = false;

  final List<_SetupStep> _steps = [
    const _SetupStep(
      label: 'Initializing local database',
      icon: Icons.storage_rounded,
    ),
    const _SetupStep(
      label: 'Starting secure server',
      icon: Icons.security_rounded,
    ),
    const _SetupStep(
      label: 'Configuring sync engine',
      icon: Icons.sync_rounded,
    ),
    const _SetupStep(
      label: 'Ready!',
      icon: Icons.check_circle_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _checkScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _runSetup();
  }

  Future<void> _runSetup() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) setState(() => _stepIndex = i);
    }
    await Future.delayed(const Duration(milliseconds: 600));
    await _checkController.forward();
    if (mounted) {
      setState(() => _isComplete = true);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        await ref.read(settingsNotifierProvider.notifier).setServerConfigured();
        context.go('/setup/pin');
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _checkController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Setting up your\nprivate finance hub',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This only takes a few seconds.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 60),
              // Server icon with pulse
              Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) => Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A1A2E),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6750A4).withOpacity(
                              0.2 + 0.2 * _pulseController.value),
                          blurRadius: 30 + 20 * _pulseController.value,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: _isComplete
                        ? ScaleTransition(
                            scale: _checkScale,
                            child: const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF4CAF50),
                              size: 60,
                            ),
                          )
                        : const Icon(
                            Icons.dns_rounded,
                            color: Color(0xFF9B72CF),
                            size: 60,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              // Steps
              ...List.generate(_steps.length, (i) {
                final step = _steps[i];
                final isDone = i < _stepIndex;
                final isActive = i == _stepIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: AnimatedOpacity(
                    opacity: i <= _stepIndex ? 1.0 : 0.3,
                    duration: const Duration(milliseconds: 400),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone
                                ? const Color(0xFF4CAF50).withOpacity(0.2)
                                : isActive
                                    ? const Color(0xFF6750A4).withOpacity(0.2)
                                    : Colors.white.withOpacity(0.05),
                            border: Border.all(
                              color: isDone
                                  ? const Color(0xFF4CAF50)
                                  : isActive
                                      ? const Color(0xFF9B72CF)
                                      : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: isDone
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFF4CAF50),
                                  size: 18,
                                )
                              : isActive
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Color(0xFF9B72CF),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      step.icon,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          step.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isDone
                                ? const Color(0xFF4CAF50)
                                : isActive
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const Spacer(),
              // Manual URL toggle
              TextButton(
                onPressed: () =>
                    setState(() => _showManualUrl = !_showManualUrl),
                child: Text(
                  _showManualUrl ? 'Hide advanced' : 'Advanced: Use custom URL',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 13,
                  ),
                ),
              ),
              if (_showManualUrl) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _urlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'http://localhost:9090',
                    hintStyle:
                        TextStyle(color: Colors.white.withOpacity(0.3)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF9B72CF)),
                    ),
                    prefixIcon: Icon(
                      Icons.link_rounded,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupStep {
  final String label;
  final IconData icon;

  const _SetupStep({required this.label, required this.icon});
}
