import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profesionalservis_mobile/core/loading/loading_overlay.dart';
import 'package:profesionalservis_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:profesionalservis_mobile/shared/widgets/app_button.dart';
import 'package:profesionalservis_mobile/shared/widgets/app_card.dart';
import 'package:profesionalservis_mobile/shared/widgets/app_input.dart';

class PosPlaceholderPage extends ConsumerWidget {
  const PosPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard POS'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(
                'Halo, ${authState.user?.name.isNotEmpty == true ? authState.user!.name : 'User'}',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda sudah login dan terhubung ke backend.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pencarian Produk',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 12),
                    AppInput(
                      label: 'Nama / SKU',
                      hint: 'Cari item...',
                      prefixIcon: Icons.search,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Simulasi Loading Global',
                icon: Icons.point_of_sale,
                onPressed: () async {
                  ref.read(appLoadingProvider.notifier).state = true;
                  await Future<void>.delayed(const Duration(milliseconds: 1200));
                  ref.read(appLoadingProvider.notifier).state = false;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
