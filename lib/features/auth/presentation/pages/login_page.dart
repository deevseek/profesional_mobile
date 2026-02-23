import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:profesionalservis_mobile/shared/widgets/app_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tenant berhasil dipilih.',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Silakan lanjutkan proses login.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Masuk ke POS',
                icon: Icons.login,
                onPressed: () => context.go('/pos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
