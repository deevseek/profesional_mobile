import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/settings/data/models/store_settings_model.dart';
import 'package:profesionalservis_mobile/features/settings/data/repositories/settings_repository.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(settingsRepositoryProvider));
});

class SettingsState {
  const SettingsState({
    required this.form,
    this.isSaving = false,
    this.successMessage,
    this.errorMessage,
  });

  final StoreSettingsModel form;
  final bool isSaving;
  final String? successMessage;
  final String? errorMessage;

  SettingsState copyWith({
    StoreSettingsModel? form,
    bool? isSaving,
    String? successMessage,
    bool clearSuccessMessage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return SettingsState(
      form: form ?? this.form,
      isSaving: isSaving ?? this.isSaving,
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  factory SettingsState.initial() => SettingsState(form: StoreSettingsModel.empty());
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._repository) : super(SettingsState.initial()) {
    loadSettings();
  }

  final SettingsRepository _repository;

  void updateStoreName(String value) {
    state = state.copyWith(
      form: state.form.copyWith(storeName: value),
      clearSuccessMessage: true,
      clearErrorMessage: true,
    );
  }

  void updateAddress(String value) {
    state = state.copyWith(
      form: state.form.copyWith(address: value),
      clearSuccessMessage: true,
      clearErrorMessage: true,
    );
  }

  void updatePhone(String value) {
    state = state.copyWith(
      form: state.form.copyWith(phone: value),
      clearSuccessMessage: true,
      clearErrorMessage: true,
    );
  }

  void updateLogo(String value) {
    state = state.copyWith(
      form: state.form.copyWith(logo: value),
      clearSuccessMessage: true,
      clearErrorMessage: true,
    );
  }

  void updateAttendanceEnabled(bool value) {
    state = state.copyWith(
      form: state.form.copyWith(attendanceEnabled: value),
      clearSuccessMessage: true,
      clearErrorMessage: true,
    );
  }

  void updateRequireSelfie(bool value) {
    state = state.copyWith(
      form: state.form.copyWith(requireSelfie: value),
      clearSuccessMessage: true,
      clearErrorMessage: true,
    );
  }

  void updateRequireLocation(bool value) {
    state = state.copyWith(
      form: state.form.copyWith(requireLocation: value),
      clearSuccessMessage: true,
      clearErrorMessage: true,
    );
  }

  Future<void> loadSettings() async {
    try {
      final settings = await _repository.getSettings();
      state = state.copyWith(form: settings, clearErrorMessage: true);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Gagal memuat pengaturan toko.');
    }
  }

  Future<bool> saveAll() async {
    state = state.copyWith(
      isSaving: true,
      clearSuccessMessage: true,
      clearErrorMessage: true,
    );

    try {
      await _repository.upsertBatch(state.form);
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Pengaturan toko berhasil disimpan.',
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menyimpan pengaturan toko.',
      );
      return false;
    }
  }
}
