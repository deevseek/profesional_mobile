import 'package:flutter/material.dart';

enum ServiceStatus { pending, checking, progress, done, delivered }

extension ServiceStatusX on ServiceStatus {
  static ServiceStatus fromRaw(String raw) {
    switch (raw.toLowerCase()) {
      case 'checking':
        return ServiceStatus.checking;
      case 'progress':
        return ServiceStatus.progress;
      case 'done':
        return ServiceStatus.done;
      case 'delivered':
        return ServiceStatus.delivered;
      default:
        return ServiceStatus.pending;
    }
  }

  String get value => name;

  String get label {
    switch (this) {
      case ServiceStatus.pending:
        return 'Pending';
      case ServiceStatus.checking:
        return 'Checking';
      case ServiceStatus.progress:
        return 'Progress';
      case ServiceStatus.done:
        return 'Done';
      case ServiceStatus.delivered:
        return 'Delivered';
    }
  }

  Color get color {
    switch (this) {
      case ServiceStatus.pending:
        return const Color(0xFF98A2B3);
      case ServiceStatus.checking:
        return const Color(0xFF175CD3);
      case ServiceStatus.progress:
        return const Color(0xFFFF7A00);
      case ServiceStatus.done:
        return const Color(0xFF12B76A);
      case ServiceStatus.delivered:
        return const Color(0xFF101828);
    }
  }

  ServiceStatus? get next {
    switch (this) {
      case ServiceStatus.pending:
        return ServiceStatus.checking;
      case ServiceStatus.checking:
        return ServiceStatus.progress;
      case ServiceStatus.progress:
        return ServiceStatus.done;
      case ServiceStatus.done:
        return ServiceStatus.delivered;
      case ServiceStatus.delivered:
        return null;
    }
  }
}
