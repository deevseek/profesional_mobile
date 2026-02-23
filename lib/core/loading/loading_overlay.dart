import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/shared/widgets/loading_indicator.dart';

final appLoadingProvider = StateProvider<bool>((ref) => false);

class LoadingOverlay extends ConsumerWidget {
  const LoadingOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(appLoadingProvider);

    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.18),
              child: const Center(child: LoadingIndicator()),
            ),
          ),
      ],
    );
  }
}
