import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profesionalservis_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:profesionalservis_mobile/shared/widgets/pro_widgets.dart';
import 'package:profesionalservis_mobile/theme/app_colors.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  String _selectedRole = 'Pemilik';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 860;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.backgroundLight, Color(0xFFEAF4FF), Color(0xFFF8FBFF)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Row(
                    children: [
                      if (isWide) ...[
                        Expanded(child: _HeroPanel()),
                        const SizedBox(width: 28),
                      ],
                      Expanded(
                        child: ProCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryNavy,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Image.asset('assets/branding/app_icon.png'),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Profesional Servis', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                                        SizedBox(height: 2),
                                        Text('Masuk ke workspace bisnis Anda', style: TextStyle(color: AppColors.slate)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email / No. HP',
                                  hintText: 'admin@tenant.com atau 0812xxxx',
                                  prefixIcon: Icon(Icons.alternate_email_rounded),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Kata sandi',
                                  hintText: 'Masukkan kata sandi',
                                  prefixIcon: Icon(Icons.lock_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 14),
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                decoration: const InputDecoration(
                                  labelText: 'Pilih peran',
                                  prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                                ),
                                items: const ['Pemilik', 'Admin', 'Kasir', 'Teknisi']
                                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                                    .toList(),
                                onChanged: (value) => setState(() => _selectedRole = value ?? _selectedRole),
                              ),
                              if (authState.errorMessage != null) ...[
                                const SizedBox(height: 12),
                                StatusChip(label: authState.errorMessage!, color: AppColors.danger),
                              ],
                              const SizedBox(height: 20),
                              FilledButton.icon(
                                icon: authState.isSubmitting
                                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.login_rounded),
                                label: Text(authState.isSubmitting ? 'Memproses...' : 'Masuk'),
                                onPressed: authState.isSubmitting
                                    ? null
                                    : () async {
                                        final success = await ref.read(authStateProvider.notifier).login(
                                              email: _emailController.text,
                                              password: _passwordController.text,
                                            );
                                        if (success && context.mounted) context.go('/pos');
                                      },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: TextButton(onPressed: () {}, child: const Text('Lupa kata sandi'))),
                                  Expanded(child: TextButton(onPressed: () {}, child: const Text('Daftar sekarang'))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.face_rounded),
                                label: const Text('Biometric / Face ID ready'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      minHeight: 560,
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryNavy, Color(0xFF0A2C68), AppColors.primaryBlue],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StatusChip(label: 'Premium SaaS Workspace', color: AppColors.cyan),
          const Spacer(),
          Text(
            'Kelola servis, POS, inventori, pelanggan, dan laporan dalam satu aplikasi.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, height: 1.15),
          ),
          const SizedBox(height: 18),
          Text(
            'Dirancang untuk pemilik toko, kasir, admin, dan teknisi agar operasional harian terasa cepat, rapi, dan profesional.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.78), height: 1.55),
          ),
          const SizedBox(height: 30),
          Row(
            children: const [
              _HeroMetric(value: '38', label: 'Servis aktif'),
              SizedBox(width: 14),
              _HeroMetric(value: '126 jt', label: 'Omzet bulan ini'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.11), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.75))),
        ]),
      ),
    );
  }
}
