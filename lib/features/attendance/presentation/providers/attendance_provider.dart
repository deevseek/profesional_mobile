import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/attendance/data/repositories/attendance_repository.dart';

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier(ref.read(attendanceRepositoryProvider))..loadTodayStatus();
});

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  AttendanceNotifier(this._repository) : super(const AttendanceState());

  final AttendanceRepository _repository;

  Future<void> loadTodayStatus() async {
    state = state.copyWith(isLoadingStatus: true, errorMessage: null);

    try {
      final data = await _repository.getTodayAttendanceStatus();
      state = state.copyWith(
        isLoadingStatus: false,
        todayStatus: data,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingStatus: false,
        errorMessage: 'Gagal memuat status absensi hari ini.',
      );
    }
  }

  Future<void> submitAttendance({
    required int shiftNumber,
    required double latitude,
    required double longitude,
    required String faceRecognitionSnapshot,
    required String attendanceType,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null);

    try {
      await _repository.submitAttendance(
        shiftNumber: shiftNumber,
        latitude: latitude,
        longitude: longitude,
        faceRecognitionSnapshot: faceRecognitionSnapshot,
        attendanceType: attendanceType,
      );
      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Absensi $attendanceType berhasil dikirim.',
      );
      await loadTodayStatus();
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal mengirim absensi. Silakan coba lagi.',
      );
    }
  }
}

class AttendanceState {
  const AttendanceState({
    this.isLoadingStatus = false,
    this.isSubmitting = false,
    this.todayStatus,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoadingStatus;
  final bool isSubmitting;
  final Map<String, dynamic>? todayStatus;
  final String? errorMessage;
  final String? successMessage;

  AttendanceState copyWith({
    bool? isLoadingStatus,
    bool? isSubmitting,
    Map<String, dynamic>? todayStatus,
    String? errorMessage,
    String? successMessage,
  }) {
    return AttendanceState(
      isLoadingStatus: isLoadingStatus ?? this.isLoadingStatus,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      todayStatus: todayStatus ?? this.todayStatus,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
