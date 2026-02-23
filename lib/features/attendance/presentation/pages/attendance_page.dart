import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:profesionalservis_mobile/features/attendance/presentation/providers/attendance_provider.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  CameraController? _cameraController;
  XFile? _snapshot;
  Position? _currentPosition;
  StreamSubscription<Position>? _locationSubscription;
  bool _isReady = false;
  String? _permissionError;

  @override
  void initState() {
    super.initState();
    _initializeAll();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeAll() async {
    final cameraStatus = await Permission.camera.request();
    final locationStatus = await Permission.locationWhenInUse.request();

    if (!cameraStatus.isGranted || !locationStatus.isGranted) {
      setState(() {
        _permissionError = 'Izin kamera dan lokasi wajib diaktifkan untuk absensi.';
      });
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _permissionError = 'GPS tidak aktif. Aktifkan GPS lalu coba lagi.';
      });
      return;
    }

    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    final controller = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
    await controller.initialize();

    final locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied ||
        locationPermission == LocationPermission.deniedForever) {
      setState(() {
        _permissionError = 'Izin lokasi belum diizinkan.';
      });
      return;
    }

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((position) {
      if (!mounted) {
        return;
      }
      setState(() => _currentPosition = position);
    });

    final initialPosition = await Geolocator.getCurrentPosition();

    if (!mounted) {
      return;
    }

    setState(() {
      _cameraController = controller;
      _currentPosition = initialPosition;
      _isReady = true;
      _permissionError = null;
    });
  }

  Future<void> _captureSelfie() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final image = await controller.takePicture();
    setState(() => _snapshot = image);
  }

  Future<void> _submit(String type) async {
    final image = _snapshot;
    final position = _currentPosition;

    if (image == null) {
      _showSnackBar('Ambil selfie terlebih dahulu.');
      return;
    }

    if (position == null) {
      _showSnackBar('Lokasi belum tersedia.');
      return;
    }

    if (position.isMocked) {
      _showSnackBar('Terdeteksi fake GPS. Nonaktifkan mock location.');
      return;
    }

    final bytes = await File(image.path).readAsBytes();
    final base64Image = base64Encode(bytes);

    await ref.read(attendanceProvider.notifier).submitAttendance(
          shiftNumber: _getAutoShift(),
          latitude: position.latitude,
          longitude: position.longitude,
          faceRecognitionSnapshot: base64Image,
          attendanceType: type,
        );
  }

  int _getAutoShift() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 1;
    }
    if (hour >= 12 && hour < 19) {
      return 2;
    }
    return 3;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: RefreshIndicator(
        onRefresh: ref.read(attendanceProvider.notifier).loadTodayStatus,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              'Absensi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text('Selfie + GPS realtime untuk check in/check out.'),
            const SizedBox(height: 12),
            if (state.errorMessage != null)
              _BannerBox(text: state.errorMessage!, color: const Color(0xFFB42318), bgColor: const Color(0xFFFFF3F2)),
            if (state.successMessage != null)
              _BannerBox(text: state.successMessage!, color: const Color(0xFF027A48), bgColor: const Color(0xFFECFDF3)),
            if (_permissionError != null)
              _BannerBox(text: _permissionError!, color: const Color(0xFFB54708), bgColor: const Color(0xFFFFFAEB)),
            const SizedBox(height: 12),
            _StatusCard(todayStatus: state.todayStatus, isLoading: state.isLoadingStatus),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Camera preview',
              child: _isReady && _cameraController != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: _cameraController!.value.aspectRatio,
                        child: CameraPreview(_cameraController!),
                      ),
                    )
                  : const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isReady ? _captureSelfie : null,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Capture Selfie'),
                  ),
                ),
              ],
            ),
            if (_snapshot != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(_snapshot!.path), height: 180, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Map preview',
              child: _currentPosition == null
                  ? const SizedBox(height: 170, child: Center(child: CircularProgressIndicator()))
                  : SizedBox(
                      height: 220,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          initialZoom: 16,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.profesionalservis.mobile',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                width: 44,
                                height: 44,
                                child: const Icon(Icons.location_pin, size: 40, color: Color(0xFF175CD3)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentPosition == null
                  ? 'Mengambil lokasi realtime...'
                  : 'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)} · Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.isSubmitting ? null : () => _submit('check_in'),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('CHECK IN'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.isSubmitting ? null : () => _submit('check_out'),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('CHECK OUT'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.todayStatus, required this.isLoading});

  final Map<String, dynamic>? todayStatus;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final status = todayStatus?['status']?.toString() ?? 'Belum ada data absensi hari ini';
    final checkIn = todayStatus?['check_in_at']?.toString() ?? '-';
    final checkOut = todayStatus?['check_out_at']?.toString() ?? '-';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1E0FF)),
      ),
      child: isLoading
          ? const LinearProgressIndicator(minHeight: 3)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Status absensi hari ini', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Status: $status'),
                Text('Check in: $checkIn'),
                Text('Check out: $checkOut'),
              ],
            ),
    );
  }
}

class _BannerBox extends StatelessWidget {
  const _BannerBox({required this.text, required this.color, required this.bgColor});

  final String text;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
