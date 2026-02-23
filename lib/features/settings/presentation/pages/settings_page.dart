import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/settings/presentation/providers/settings_provider.dart';
import 'package:profesionalservis_mobile/shared/widgets/app_button.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final TextEditingController _storeNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _logoController;

  @override
  void initState() {
    super.initState();
    final form = ref.read(settingsProvider).form;
    _storeNameController = TextEditingController(text: form.storeName);
    _addressController = TextEditingController(text: form.address);
    _phoneController = TextEditingController(text: form.phone);
    _logoController = TextEditingController(text: form.logo);
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return SingleChildScrollView(
      key: const ValueKey('settings-page'),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengaturan Toko',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lengkapi profil toko dan konfigurasi absensi dalam satu form profesional.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF475467),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Profil Toko'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _storeNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama toko',
                      prefixIcon: Icon(Icons.storefront_rounded),
                    ),
                    onChanged: notifier.updateStoreName,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Alamat',
                      prefixIcon: Icon(Icons.location_on_rounded),
                    ),
                    onChanged: notifier.updateAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telepon',
                      prefixIcon: Icon(Icons.phone_rounded),
                    ),
                    onChanged: notifier.updatePhone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _logoController,
                    decoration: const InputDecoration(
                      labelText: 'Logo (URL)',
                      prefixIcon: Icon(Icons.image_rounded),
                    ),
                    onChanged: notifier.updateLogo,
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Pengaturan Absensi'),
                  const SizedBox(height: 8),
                  _SwitchTile(
                    title: 'Aktifkan fitur absensi',
                    subtitle: 'Karyawan dapat melakukan check-in dan check-out.',
                    value: state.form.attendanceEnabled,
                    onChanged: notifier.updateAttendanceEnabled,
                  ),
                  _SwitchTile(
                    title: 'Wajib selfie saat absensi',
                    subtitle: 'Validasi identitas dengan kamera saat check-in.',
                    value: state.form.requireSelfie,
                    onChanged: state.form.attendanceEnabled
                        ? notifier.updateRequireSelfie
                        : null,
                  ),
                  _SwitchTile(
                    title: 'Wajib lokasi saat absensi',
                    subtitle: 'Pastikan karyawan berada di area kerja.',
                    value: state.form.requireLocation,
                    onChanged: state.form.attendanceEnabled
                        ? notifier.updateRequireLocation
                        : null,
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFB42318),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (state.successMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.successMessage!,
                      style: const TextStyle(
                        color: Color(0xFF027A48),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  AppButton(
                    label: state.isSaving ? 'Menyimpan...' : 'Save all',
                    icon: Icons.save_rounded,
                    onPressed: state.isSaving
                        ? null
                        : () async {
                            if (_storeNameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Nama toko wajib diisi.')),
                              );
                              return;
                            }

                            await notifier.saveAll();
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
