import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profesionalservis_mobile/shared/widgets/app_button.dart';
import 'package:profesionalservis_mobile/shared/widgets/app_input.dart';
import 'package:profesionalservis_mobile/tenant/tenant_state_provider.dart';

class TenantSelectionPage extends ConsumerStatefulWidget {
  const TenantSelectionPage({super.key});

  @override
  ConsumerState<TenantSelectionPage> createState() => _TenantSelectionPageState();
}

class _TenantSelectionPageState extends ConsumerState<TenantSelectionPage> {
  late final TextEditingController _tenantController;

  @override
  void initState() {
    super.initState();
    _tenantController = TextEditingController();
  }

  @override
  void dispose() {
    _tenantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tenantState = ref.watch(tenantStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Tenant')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Masukkan kode tenant Anda',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Link toko Anda biasanya berbentuk https://{kode-tenant}.profesionalservis.com',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    controller: _tenantController,
                    label: 'Kode Tenant',
                    hint:
                        'Link toko Anda biasanya berbentuk https://{kode-tenant}.profesionalservis.com',
                    prefixIcon: Icons.apartment,
                  ),
                  if (tenantState.errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      tenantState.errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppButton(
                    label: tenantState.isSubmitting ? 'Memproses...' : 'Lanjutkan',
                    icon: Icons.arrow_forward,
                    onPressed: tenantState.isSubmitting
                        ? null
                        : () async {
                            final isSuccess = await ref
                                .read(tenantStateProvider.notifier)
                                .resolveTenant(_tenantController.text);

                            if (isSuccess && context.mounted) {
                              context.go('/login');
                            }
                          },
                  ),
                  if (tenantState.isSubmitting) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
