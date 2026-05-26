import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../providers/local_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    const _OnboardingPage(
      title: 'Your finances,\ncompletely private',
      subtitle:
          'All your data lives on your device. No cloud, no tracking, no compromises.',
      accentColor: Color(0xFF9B72CF),
      secondaryColor: Color(0xFF6750A4),
      iconData: Icons.lock_rounded,
      illustrationType: 0,
    ),
    const _OnboardingPage(
      title: 'Smart SMS\nimport',
      subtitle:
          'Transactions automatically detected from bank SMS messages. Review, edit, and approve in seconds.',
      accentColor: Color(0xFF4CAF50),
      secondaryColor: Color(0xFF1B5E20),
      iconData: Icons.sms_rounded,
      illustrationType: 1,
    ),
    const _OnboardingPage(
      title: 'Works offline,\nalways',
      subtitle:
          'Full functionality without internet. Your finances work when you do.',
      accentColor: Color(0xFF2196F3),
      secondaryColor: Color(0xFF0D47A1),
      iconData: Icons.offline_bolt_rounded,
      illustrationType: 2,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(settingsNotifierProvider.notifier).setOnboardingComplete();
    if (mounted) context.go('/setup/server');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (context, i) => _OnboardingPageView(page: _pages[i]),
          ),
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 56),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: _pages[_currentPage].accentColor,
                      dotColor: Colors.white24,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pages[_currentPage].accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            _currentPage == _pages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String subtitle;
  final Color accentColor;
  final Color secondaryColor;
  final IconData iconData;
  final int illustrationType;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.secondaryColor,
    required this.iconData,
    required this.illustrationType,
  });
}

class _OnboardingPageView extends StatefulWidget {
  final _OnboardingPage page;

  const _OnboardingPageView({required this.page});

  @override
  State<_OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<_OnboardingPageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 80),
          // Illustration area
          Expanded(
            flex: 5,
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => CustomPaint(
                  painter: _IllustrationPainter(
                    type: widget.page.illustrationType,
                    progress: _controller.value,
                    accentColor: widget.page.accentColor,
                    secondaryColor: widget.page.secondaryColor,
                  ),
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: Center(
                      child: Icon(
                        widget.page.iconData,
                        size: 80,
                        color: widget.page.accentColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Text area
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.page.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.page.subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.6),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 140),
        ],
      ),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  final int type;
  final double progress;
  final Color accentColor;
  final Color secondaryColor;

  _IllustrationPainter({
    required this.type,
    required this.progress,
    required this.accentColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;

    // Outer glow ring
    final glowPaint = Paint()
      ..color = accentColor.withOpacity(0.1 + 0.05 * math.sin(progress * math.pi))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 20 * progress, glowPaint);

    // Main circle
    final circlePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withOpacity(0.2),
          secondaryColor.withOpacity(0.05),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, circlePaint);

    // Border
    final borderPaint = Paint()
      ..color = accentColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);

    // Orbit dots
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * math.pi * 2 + progress * math.pi * 2;
      final orbitRadius = radius * 0.75;
      final dotX = center.dx + math.cos(angle) * orbitRadius;
      final dotY = center.dy + math.sin(angle) * orbitRadius;
      final dotPaint = Paint()
        ..color = accentColor.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_IllustrationPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
