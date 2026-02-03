import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/attendance_model.dart';
import 'attendance_controller.dart';

class AttendanceFormPage extends StatefulWidget {
  const AttendanceFormPage({super.key, required this.employeeId});

  final String employeeId;

  @override
  State<AttendanceFormPage> createState() => _AttendanceFormPageState();
}

class _AttendanceFormPageState extends State<AttendanceFormPage> {
  static const List<String> _attendanceTypes = ['checkin', 'checkout'];

  final AttendanceController _controller = AttendanceController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();

  String _attendanceType = 'checkin';
  TimeOfDay? _checkInTime;
  TimeOfDay? _checkOutTime;
  XFile? _snapshotFile;
  String? _snapshotPreview;

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(DateTime.now());
  }

  @override
  void dispose() {
    _controller.dispose();
    _dateController.dispose();
    _noteController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _checkInController.dispose();
    _checkOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Attendance (Face Recognition)'),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildHeader(context),
                  if (_controller.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildMessageBanner(
                        context,
                        _controller.errorMessage!,
                        isError: true,
                      ),
                    ),
                  if (_controller.successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildMessageBanner(
                        context,
                        _controller.successMessage!,
                        isError: false,
                      ),
                    ),
                  DropdownButtonFormField<String>(
                    value: _attendanceType,
                    decoration: const InputDecoration(
                      labelText: 'Attendance type *',
                      prefixIcon: Icon(Icons.how_to_reg_outlined),
                    ),
                    items: _attendanceTypes
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _attendanceType = value;
                        if (_attendanceType == 'checkin') {
                          _checkOutTime = null;
                          _checkOutController.clear();
                        } else {
                          _checkInTime = null;
                          _checkInController.clear();
                        }
                      });
                    },
                  ),
                  _buildFieldError('attendance_type'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Attendance date *',
                      hintText: 'YYYY-MM-DD',
                      prefixIcon: Icon(Icons.event_outlined),
                    ),
                    readOnly: true,
                    onTap: () => _pickDate(context),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Attendance date is required.';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  _buildFieldError('attendance_date'),
                  const SizedBox(height: 16),
                  _buildTimeField(
                    label: 'Check-in time *',
                    controller: _checkInController,
                    enabled: _attendanceType == 'checkin',
                    onTap: () => _pickTime(context, isCheckIn: true),
                  ),
                  if (_attendanceType == 'checkin')
                    _buildInlineHelper('Required for check-in'),
                  _buildFieldError('check_in_time'),
                  const SizedBox(height: 16),
                  _buildTimeField(
                    label: 'Check-out time *',
                    controller: _checkOutController,
                    enabled: _attendanceType == 'checkout',
                    onTap: () => _pickTime(context, isCheckIn: false),
                  ),
                  if (_attendanceType == 'checkout')
                    _buildInlineHelper('Required for check-out'),
                  _buildFieldError('check_out_time'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                    maxLines: 3,
                  ),
                  _buildFieldError('note'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _latitudeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(
                      labelText: 'Location latitude *',
                      prefixIcon: Icon(Icons.my_location_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Latitude is required.';
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'Latitude must be a number.';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  _buildFieldError('location_latitude'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _longitudeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(
                      labelText: 'Location longitude *',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Longitude is required.';
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'Longitude must be a number.';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  _buildFieldError('location_longitude'),
                  const SizedBox(height: 16),
                  _buildSnapshotSection(context),
                  _buildFieldError('face_recognition_snapshot'),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: _controller.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.verified_outlined),
                    label: const Text('Submit Attendance'),
                    onPressed: _controller.isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catat absensi dengan verifikasi wajah.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan wajah terlihat jelas dan berada dalam radius lokasi toko.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBanner(BuildContext context, String message, {required bool isError}) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: isError ? colors.errorContainer : colors.tertiaryContainer,
      child: ListTile(
        leading: Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: isError ? colors.onErrorContainer : colors.onTertiaryContainer,
        ),
        title: Text(
          message,
          style: TextStyle(
            color: isError ? colors.onErrorContainer : colors.onTertiaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildFieldError(String field) {
    final errors = _controller.fieldErrors[field];
    if (errors == null || errors.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        errors.join('\n'),
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }

  Widget _buildInlineHelper(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      readOnly: true,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.access_time),
      ),
      controller: controller,
      onTap: enabled ? onTap : null,
      validator: (value) {
        if (!enabled) {
          return null;
        }
        if (value == null || value.trim().isEmpty) {
          return 'Required when $label is active.';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _buildSnapshotSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Face recognition snapshot *',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (_snapshotPreview != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              base64Decode(_snapshotPreview!.split(',').last),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade500),
                const SizedBox(height: 8),
                Text(
                  'Belum ada foto wajah',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Ambil Foto'),
                onPressed: _controller.isSubmitting ? null : () => _pickSnapshot(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Pilih Galeri'),
                onPressed:
                    _controller.isSubmitting ? null : () => _pickSnapshot(ImageSource.gallery),
              ),
            ),
          ],
        ),
        if (_snapshotFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'File: ${_snapshotFile!.name}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Future<void> _pickSnapshot(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 720,
    );
    if (picked == null) {
      return;
    }

    final bytes = await picked.readAsBytes();
    final extension = picked.path.split('.').last.toLowerCase();
    final mimeType = _mapMimeType(extension);
    final base64Image = base64Encode(bytes);

    setState(() {
      _snapshotFile = picked;
      _snapshotPreview = 'data:$mimeType;base64,$base64Image';
    });
  }

  String _mapMimeType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final parsed = _parseDate(_dateController.text) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: parsed,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      _dateController.text = _formatDate(picked);
    }
  }

  Future<void> _pickTime(BuildContext context, {required bool isCheckIn}) async {
    final initial = isCheckIn ? (_checkInTime ?? TimeOfDay.now()) : (_checkOutTime ?? TimeOfDay.now());
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (isCheckIn) {
        _checkInTime = picked;
        _checkInController.text = _formatTimeOfDay(picked);
      } else {
        _checkOutTime = picked;
        _checkOutController.text = _formatTimeOfDay(picked);
      }
    });
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatTimeOfDay(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  DateTime? _parseDate(String value) {
    if (value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value.trim());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_snapshotPreview == null) {
      _controller.clearMessages();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto wajah wajib diunggah.')),
      );
      return;
    }

    if (_attendanceType == 'checkin' && _checkInTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu check-in wajib diisi.')),
      );
      return;
    }

    if (_attendanceType == 'checkout' && _checkOutTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu check-out wajib diisi.')),
      );
      return;
    }

    final date = _parseDate(_dateController.text) ?? DateTime.now();
    final latitude = double.parse(_latitudeController.text.trim());
    final longitude = double.parse(_longitudeController.text.trim());

    final request = AttendanceRequest(
      attendanceType: _attendanceType,
      employeeId: widget.employeeId,
      attendanceDate: date,
      checkInTime: _attendanceType == 'checkin' ? _formatTimeOfDay(_checkInTime!) : null,
      checkOutTime: _attendanceType == 'checkout' ? _formatTimeOfDay(_checkOutTime!) : null,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      faceRecognitionSnapshot: _snapshotPreview,
      locationLatitude: latitude,
      locationLongitude: longitude,
    );

    final success = await _controller.createAttendance(request);
    if (!success) {
      return;
    }

    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }
}
