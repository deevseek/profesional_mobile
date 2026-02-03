import 'package:flutter/material.dart';

import '../domain/attendance_log_model.dart';
import 'attendance_log_controller.dart';

class AttendanceLogListPage extends StatefulWidget {
  const AttendanceLogListPage({super.key});

  @override
  State<AttendanceLogListPage> createState() => _AttendanceLogListPageState();
}

class _AttendanceLogListPageState extends State<AttendanceLogListPage> {
  final AttendanceLogController _controller = AttendanceLogController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _deviceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userIdController.addListener(() {
      setState(() {});
    });
    _typeController.addListener(() {
      setState(() {});
    });
    _deviceController.addListener(() {
      setState(() {});
    });
    _controller.loadAttendanceLogs();
  }

  @override
  void dispose() {
    _controller.dispose();
    _userIdController.dispose();
    _typeController.dispose();
    _deviceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Attendance Logs'),
            actions: [
              IconButton(
                onPressed: _controller.isLoading ? null : _refreshLogs,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchBar(context),
              _buildFilterRow(context),
              if (_controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildErrorBanner(_controller.errorMessage!),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _refreshLogs(),
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

  void _refreshLogs() {
    _controller.loadAttendanceLogs(
      userId: _userIdController.text,
      type: _typeController.text,
      deviceInfo: _deviceController.text,
      page: 1,
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SearchBar(
        controller: _userIdController,
        hintText: 'Filter by user ID',
        leading: const Icon(Icons.search),
        trailing: [
          if (_userIdController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _userIdController.clear();
                _refreshLogs();
              },
            ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _controller.isLoading ? null : _refreshLogs,
          ),
        ],
        onSubmitted: (_) => _refreshLogs(),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _typeController,
              decoration: InputDecoration(
                labelText: 'Type',
                prefixIcon: const Icon(Icons.category_outlined),
                suffixIcon: _typeController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _typeController.clear();
                          _refreshLogs();
                        },
                      )
                    : null,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _refreshLogs(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _deviceController,
              decoration: InputDecoration(
                labelText: 'Device',
                prefixIcon: const Icon(Icons.devices_other_outlined),
                suffixIcon: _deviceController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _deviceController.clear();
                          _refreshLogs();
                        },
                      )
                    : null,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _refreshLogs(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    if (_controller.isLoading && _controller.attendanceLogs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.attendanceLogs.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Icon(Icons.event_available_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No attendance logs found',
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
      itemCount: _controller.attendanceLogs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final log = _controller.attendanceLogs[index];
        final statusLabel = log.type;
        return Card(
          elevation: 1,
          child: ListTile(
            leading: CircleAvatar(
              child: Text(_initialForLog(log)),
            ),
            title: Text(_titleForLog(log)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (log.capturedAt != null)
                  Text('Captured: ${_formatDateTime(log.capturedAt)}'),
                if (log.confidence != null)
                  Text('Confidence: ${(log.confidence! * 100).toStringAsFixed(1)}%'),
                if (log.ipAddress != null && log.ipAddress!.isNotEmpty)
                  Text('IP: ${log.ipAddress}'),
                if (log.deviceInfo != null && log.deviceInfo!.isNotEmpty)
                  Text('Device: ${log.deviceInfo}'),
                if (log.createdAt != null)
                  Text('Logged: ${_formatDateTime(log.createdAt)}'),
                if (statusLabel != null && statusLabel.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildStatusBadge(context, statusLabel),
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
                ? () => _controller.loadAttendanceLogs(
                      userId: _userIdController.text,
                      type: _typeController.text,
                      deviceInfo: _deviceController.text,
                      page: meta.currentPage - 1,
                    )
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: canGoForward
                ? () => _controller.loadAttendanceLogs(
                      userId: _userIdController.text,
                      type: _typeController.text,
                      deviceInfo: _deviceController.text,
                      page: meta.currentPage + 1,
                    )
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  String _titleForLog(AttendanceLog log) {
    if (log.userId != null && log.userId!.isNotEmpty) {
      return 'User ${log.userId}';
    }
    return log.id.isNotEmpty ? 'Log ${log.id}' : 'Attendance Log';
  }

  String _initialForLog(AttendanceLog log) {
    final title = _titleForLog(log);
    return title.isNotEmpty ? title[0].toUpperCase() : '?';
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '—';
    }
    return value.toLocal().toString();
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
    if (normalized.contains('fail') || normalized.contains('reject')) {
      return Theme.of(context).colorScheme.error;
    }
    if (normalized.contains('success') || normalized.contains('pass')) {
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
