import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:profesionalservis_mobile/theme/app_colors.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    this.title = 'Terjadi kesalahan',
    required this.message,
    this.onReload,
  });

  final String title;
  final String message;
  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context) {
    final safeMessage = message.trim().isEmpty ? 'Silakan muat ulang halaman.' : message;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                kReleaseMode ? 'Mohon coba kembali.' : safeMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.slate, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Muat Ulang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppErrorBoundary extends StatefulWidget {
  const AppErrorBoundary({super.key, required this.child});

  final Widget child;

  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  Object? _error;

  @override
  void didUpdateWidget(covariant AppErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child.key != widget.child.key) {
      _error = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return AppErrorView(
        message: error.toString(),
        onReload: () => setState(() => _error = null),
      );
    }

    try {
      return widget.child;
    } catch (error) {
      _error = error;
      return AppErrorView(
        message: error.toString(),
        onReload: () => setState(() => _error = null),
      );
    }
  }
}
