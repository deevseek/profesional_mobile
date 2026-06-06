import 'package:flutter/material.dart';
import 'package:profesionalservis_mobile/theme/app_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryNavy, Color(0xFF082B68), AppColors.primaryBlue],
                ),
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: -60,
            child: _Glow(size: 220, color: AppColors.cyan.withValues(alpha: 0.35)),
          ),
          Positioned(
            bottom: -80,
            left: -70,
            child: _Glow(size: 260, color: AppColors.teal.withValues(alpha: 0.28)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 112,
                    height: 112,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 40, offset: const Offset(0, 22)),
                      ],
                    ),
                    child: Image.asset('assets/branding/splash_logo.png', fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'PROFESIONAL SERVIS',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sistem Manajemen Servis, POS & Inventori Terintegrasi',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.82), height: 1.45),
                  ),
                  const SizedBox(height: 42),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: const LinearProgressIndicator(
                      minHeight: 5,
                      backgroundColor: Color(0x33FFFFFF),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyan),
                    ),
                  ),
                  const Spacer(),
                  _CityLine(color: Colors.white.withValues(alpha: 0.16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 90)]),
    );
  }
}

class _CityLine extends StatelessWidget {
  const _CityLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(16, (index) {
          final heights = [28, 44, 36, 58, 42, 68, 34, 50, 62, 30, 48, 70, 40, 56, 32, 46];
          return Container(
            width: 14,
            height: heights[index].toDouble(),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          );
        }),
      ),
    );
  }
}
