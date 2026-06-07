import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profesionalservis_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:profesionalservis_mobile/tenant/tenant_state_provider.dart';
import 'package:profesionalservis_mobile/theme/app_colors.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> with SingleTickerProviderStateMixin {
  static const _minimumSplashDuration = Duration(milliseconds: 1400);
  static const _targetProgress = 0.78;

  late final AnimationController _controller;
  late final Animation<double> _introAnimation;
  bool _minimumSplashElapsed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
    _introAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(_minimumSplashDuration);
    if (!mounted) return;
    _minimumSplashElapsed = true;
    _navigateWhenReady();
  }

  void _navigateWhenReady() {
    if (!_minimumSplashElapsed || !mounted) return;

    final tenantState = ref.read(tenantStateProvider);
    final authState = ref.read(authStateProvider);
    if (tenantState.isBootstrapping || authState.isBootstrapping) return;

    if (!tenantState.hasTenant) {
      context.go('/tenant');
      return;
    }

    context.go(authState.isAuthenticated ? '/home' : '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen<TenantState>(tenantStateProvider, (_, __) => _navigateWhenReady())
      ..listen<AuthState>(authStateProvider, (_, __) => _navigateWhenReady());

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _SplashBackground()),
          Positioned.fill(child: CustomPaint(painter: _CitySkylinePainter(animation: _controller))),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final shortestSide = math.min(constraints.maxWidth, constraints.maxHeight);
                final logoSize = shortestSide.clamp(92.0, 124.0).toDouble();
                final compact = constraints.maxHeight < 620;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(28, compact ? 18 : 28, 28, compact ? 22 : 34),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          final progress = ((_controller.value / _targetProgress).clamp(0.0, 1.0).toDouble()) * _targetProgress;

                          return Column(
                            children: [
                              Spacer(flex: compact ? 1 : 2),
                              FadeTransition(
                                opacity: _introAnimation,
                                child: Transform.scale(
                                  scale: 0.9 + (_introAnimation.value * 0.1),
                                  child: _BrandMark(size: logoSize),
                                ),
                              ),
                              SizedBox(height: compact ? 18 : 24),
                              Text(
                                'PROFESIONAL\nSERVIS',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      height: 1.04,
                                      letterSpacing: 2.4,
                                    ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Sistem Manajemen Servis,\nPOS & Inventori Terintegrasi',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.75),
                                      height: 1.42,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Spacer(flex: compact ? 1 : 3),
                              _LoadingPanel(progress: progress),
                              SizedBox(height: compact ? 86 : 112),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(color: AppColors.cyan.withValues(alpha: 0.35), blurRadius: 42, spreadRadius: 2),
          BoxShadow(color: Colors.black.withValues(alpha: 0.42), blurRadius: 36, offset: const Offset(0, 22)),
        ],
      ),
      child: Image.asset('assets/branding/splash_logo.png', fit: BoxFit.contain),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round().clamp(0, 78);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Memuat data, mohon tunggu...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
          ),
        ),
      ],
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PatternPainter(),
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF061225), Color(0xFF071A3D), Color(0xFF020617)],
            stops: [0, 0.48, 1],
          ),
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.045);
    const gap = 26.0;
    for (double y = 12; y < size.height; y += gap) {
      for (double x = 12; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), 1.05, dotPaint);
      }
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.cyan.withValues(alpha: 0.22), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.82, size.height * 0.18), radius: size.width * 0.44));
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.18), size.width * 0.44, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CitySkylinePainter extends CustomPainter {
  _CitySkylinePainter({required this.animation}) : super(repaint: animation);

  final Animation<double> animation;

  static const _heights = [0.24, 0.36, 0.29, 0.48, 0.33, 0.56, 0.39, 0.64, 0.44, 0.31, 0.52, 0.68, 0.37, 0.58, 0.42, 0.50];

  @override
  void paint(Canvas canvas, Size size) {
    final skylineHeight = math.min(size.height * 0.26, 190.0);
    final baseY = size.height;
    final buildingWidth = size.width / _heights.length;
    final reveal = Curves.easeOutCubic.transform(animation.value.clamp(0.0, 1.0).toDouble());

    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.cyan.withValues(alpha: 0.26 * reveal), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, baseY - skylineHeight - 34, size.width, skylineHeight));
    canvas.drawRect(Rect.fromLTWH(0, baseY - skylineHeight - 34, size.width, skylineHeight), glowPaint);

    for (var i = 0; i < _heights.length; i++) {
      final left = i * buildingWidth;
      final width = buildingWidth * (i.isEven ? 0.72 : 0.84);
      final height = skylineHeight * _heights[i] * reveal;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left + (buildingWidth - width) / 2, baseY - height, width, height),
        const Radius.circular(5),
      );
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.cyan.withValues(alpha: 0.72), AppColors.teal.withValues(alpha: 0.38), const Color(0xFF0B63F6).withValues(alpha: 0.2)],
        ).createShader(rect.outerRect);
      canvas.drawRRect(rect, paint);

      final windowPaint = Paint()..color = Colors.white.withValues(alpha: 0.42 * reveal);
      for (double y = rect.outerRect.top + 12; y < rect.outerRect.bottom - 8; y += 18) {
        for (double x = rect.outerRect.left + 8; x < rect.outerRect.right - 6; x += 14) {
          if (((x + y + i) % 3) > 1) {
            canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 3, 3), const Radius.circular(2)), windowPaint);
          }
        }
      }
    }

    final horizonPaint = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.62 * reveal)
      ..strokeWidth = 1.4;
    canvas.drawLine(Offset(0, baseY - 1), Offset(size.width, baseY - 1), horizonPaint);
  }

  @override
  bool shouldRepaint(covariant _CitySkylinePainter oldDelegate) => oldDelegate.animation != animation;
}
