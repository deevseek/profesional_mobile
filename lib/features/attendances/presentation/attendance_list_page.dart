import 'package:flutter/material.dart';

import '../domain/attendance_model.dart';
import 'attendance_controller.dart';
import 'attendance_form_page.dart';

class AttendanceListPage extends StatefulWidget {
  const AttendanceListPage({super.key});

  @override
  State<AttendanceListPage> createState() => _AttendanceListPageState();
}

class _AttendanceListPageState extends State<AttendanceListPage> {
  final AttendanceController _controller = AttendanceController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _methodController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _employeeIdController.addListener(() {
      setState(() {});
    });
    _statusController.addListener(() {
      setState(() {});
    });
    _methodController.addListener(() {
      setState(() {});
    });
    _controller.loadAttendances();
  }

  @override
  void dispose() {
    _controller.dispose();
    _employeeIdController.dispose();
    _statusController.dispose();
    _methodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Attendance'),
            actions: [
              IconButton(
                onPressed: _controller.isLoading ? null : _refreshAttendances,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _controller.isLoading ? null : _openAttendanceForm,
            icon: const Icon(Icons.add_task_outlined),
            label: const Text('New Attendance'),
          ),
          body: Column(
            children: [
              _buildSearchBar(context),
              _buildFilterRow(context),
              _buildDateFilter(context),
              if (_controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildErrorBanner(_controller.errorMessage!),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _refreshAttendances(),
                  child: _buildList(context),
                ),
              ),
              _buildPagination(context),
            ],
          ),
        );
      },
    );
  }

  void _refreshAttendances() {
    _controller.loadAttendances(
      employeeId: _employeeIdController.text,
      status: _statusController.text,
      method: _methodController.text,
      attendanceDate: _controller.attendanceDate,
      page: 1,
    );
  }

  Future<void> _openAttendanceForm() async {
    final employeeId = _employeeIdController.text.trim().isNotEmpty
        ? _employeeIdController.text.trim()
        : await _promptEmployeeId();
    if (employeeId == null || employeeId.isEmpty) {
      return;
    }
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AttendanceFormPage(employeeId: employeeId),
      ),
    );
    if (created == true) {
      _controller.loadAttendances(page: _controller.page);
    }
  }

  Future<String?> _promptEmployeeId() async {
    final textController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Masukkan Employee ID'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Contoh: 10',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(textController.text.trim()),
              child: const Text('Lanjut'),
            ),
          ],
        );
      },
    );
    textController.dispose();
    return result;
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SearchBar(
        controller: _employeeIdController,
        hintText: 'Filter by employee ID',
        leading: const Icon(Icons.search),
        trailing: [
          if (_employeeIdController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _employeeIdController.clear();
                _refreshAttendances();
              },
            ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _controller.isLoading ? null : _refreshAttendances,
          ),
        ],
        onSubmitted: (_) => _refreshAttendances(),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _statusController,
              decoration: InputDecoration(
                labelText: 'Status',
                prefixIcon: const Icon(Icons.flag_outlined),
                suffixIcon: _statusController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _statusController.clear();
                          _refreshAttendances();
                        },
                      )
                    : null,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _refreshAttendances(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _methodController,
              decoration: InputDecoration(
                labelText: 'Method',
                prefixIcon: const Icon(Icons.fingerprint_outlined),
                suffixIcon: _methodController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _methodController.clear();
                          _refreshAttendances();
                        },
                      )
                    : null,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _refreshAttendances(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    final selectedDate = _controller.attendanceDate;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _controller.isLoading ? null : () => _selectDate(context),
              icon: const Icon(Icons.event_outlined),
              label: Text(
                selectedDate == null
                    ? 'Filter by date'
                    : 'Date: ${_formatDate(selectedDate)}',
              ),
            ),
          ),
          if (selectedDate != null) ...[
            const SizedBox(width: 12),
            IconButton(
              tooltip: 'Clear date filter',
              onPressed: _controller.isLoading
                  ? null
                  : () {
                      _controller.loadAttendances(
                        employeeId: _employeeIdController.text,
                        status: _statusController.text,
                        method: _methodController.text,
                        attendanceDate: null,
                        page: 1,
                      );
                    },
              icon: const Icon(Icons.close),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.attendanceDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      _controller.loadAttendances(
        employeeId: _employeeIdController.text,
        status: _statusController.text,
        method: _methodController.text,
        attendanceDate: picked,
        page: 1,
      );
    }
  }

  Widget _buildList(BuildContext context) {
    if (_controller.isLoading && _controller.attendances.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.attendances.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Icon(Icons.fingerprint_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No attendance records found',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or refresh the list.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _controller.attendances.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final attendance = _controller.attendances[index];
        final status = attendance.status;
        return Card(
          elevation: 1,
          child: ListTile(
            leading: CircleAvatar(
              child: Text(_initialForAttendance(attendance)),
            ),
            title: Text(_titleForAttendance(attendance)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (attendance.attendanceDate != null)
                  Text('Date: ${_formatDate(attendance.attendanceDate!)}'),
                if (attendance.checkInTime != null && attendance.checkInTime!.isNotEmpty)
                  Text('Check in: ${attendance.checkInTime}'),
                if (attendance.checkOutTime != null && attendance.checkOutTime!.isNotEmpty)
                  Text('Check out: ${attendance.checkOutTime}'),
                if (attendance.method != null && attendance.method!.isNotEmpty)
                  Text('Method: ${attendance.method}'),
                if (attendance.lateMinutes != null)
                  Text('Late: ${attendance.lateMinutes} min'),
                if (attendance.note != null && attendance.note!.isNotEmpty)
                  Text('Note: ${attendance.note}'),
                if (status != null && status.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildStatusBadge(context, status),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPagination(BuildContext context) {
    final meta = _controller.meta;
    if (meta == null) {
      return const SizedBox.shrink();
    }

    final canGoBack = meta.currentPage > 1;
    final canGoForward = meta.currentPage < meta.lastPage;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Page ${meta.currentPage} of ${meta.lastPage} · ${meta.total} total',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          IconButton(
            onPressed: canGoBack
                ? () => _controller.loadAttendances(
                      employeeId: _employeeIdController.text,
                      status: _statusController.text,
                      method: _methodController.text,
                      attendanceDate: _controller.attendanceDate,
                      page: meta.currentPage - 1,
                    )
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: canGoForward
                ? () => _controller.loadAttendances(
                      employeeId: _employeeIdController.text,
                      status: _statusController.text,
                      method: _methodController.text,
                      attendanceDate: _controller.attendanceDate,
                      page: meta.currentPage + 1,
                    )
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  String _titleForAttendance(Attendance attendance) {
    final name = attendance.employee?.user?.name;
    if (name != null && name.isNotEmpty) {
      return name;
    }
    if (attendance.employeeId != null && attendance.employeeId!.isNotEmpty) {
      return 'Employee ${attendance.employeeId}';
    }
    return attendance.id.isNotEmpty ? 'Attendance ${attendance.id}' : 'Attendance';
  }

  String _initialForAttendance(Attendance attendance) {
    final title = _titleForAttendance(attendance);
    return title.isNotEmpty ? title[0].toUpperCase() : '?';
  }

  String _formatDate(DateTime value) {
    return value.toLocal().toString().split(' ').first;
  }

  Widget _buildStatusBadge(BuildContext context, String label) {
    final color = _statusColor(context, label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _titleCase(label),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }

  Color _statusColor(BuildContext context, String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('late')) {
      return Colors.orange;
    }
    if (normalized.contains('absent') || normalized.contains('missed')) {
      return Theme.of(context).colorScheme.error;
    }
    if (normalized.contains('present') || normalized.contains('on time')) {
      return Colors.green;
    }
    return Theme.of(context).colorScheme.primary;
  }

  String _titleCase(String label) {
    return label
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  Widget _buildErrorBanner(String message) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        leading: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer),
        title: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
      ),
    );
  }
}
