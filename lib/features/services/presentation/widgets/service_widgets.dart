import 'package:flutter/material.dart';
import 'package:profesionalservis_mobile/features/services/domain/service_status.dart';

class ServiceStatusBadge extends StatelessWidget {
  const ServiceStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final resolved = ServiceStatusX.fromRaw(status);
    final color = resolved.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        resolved.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ServiceSkeletonCard extends StatelessWidget {
  const ServiceSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 114,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
    );
  }
}

class ServiceEmptyState extends StatelessWidget {
  const ServiceEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_rounded, size: 40, color: Color(0xFF98A2B3)),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(color: Color(0xFF667085))),
          ],
        ),
      ),
    );
  }
}

class ServiceErrorState extends StatelessWidget {
  const ServiceErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Gagal memuat service.'),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}
