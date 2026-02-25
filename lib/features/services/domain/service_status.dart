import 'package:flutter/material.dart';

enum ServiceStatus { menunggu, diagnosa, dikerjakan, selesai, diambil }

extension ServiceStatusX on ServiceStatus {
  static ServiceStatus fromRaw(String raw) {
    switch (raw.toLowerCase()) {
      case 'diagnosa':
      case 'diagnosis':
      case 'checking':
        return ServiceStatus.diagnosa;
      case 'dikerjakan':
      case 'progress':
      case 'in_progress':
        return ServiceStatus.dikerjakan;
      case 'selesai':
      case 'done':
        return ServiceStatus.selesai;
      case 'diambil':
      case 'delivered':
      case 'picked_up':
        return ServiceStatus.diambil;
      case 'created':
      case 'pending':
      case 'menunggu':
      default:
        return ServiceStatus.menunggu;
    }
  }

  String get value => name;

  String get apiValue {
    switch (this) {
      case ServiceStatus.menunggu:
        return 'menunggu';
      case ServiceStatus.diagnosa:
        return 'diagnosis';
      case ServiceStatus.dikerjakan:
        return 'in_progress';
      case ServiceStatus.selesai:
        return 'done';
      case ServiceStatus.diambil:
        return 'picked_up';
    }
  }

  String get label {
    switch (this) {
      case ServiceStatus.menunggu:
        return 'Menunggu';
      case ServiceStatus.diagnosa:
        return 'Diagnosa';
      case ServiceStatus.dikerjakan:
        return 'Dikerjakan';
      case ServiceStatus.selesai:
        return 'Selesai';
      case ServiceStatus.diambil:
        return 'Diambil';
    }
  }

  Color get color {
    switch (this) {
      case ServiceStatus.menunggu:
        return const Color(0xFF98A2B3);
      case ServiceStatus.diagnosa:
        return const Color(0xFF175CD3);
      case ServiceStatus.dikerjakan:
        return const Color(0xFFFF7A00);
      case ServiceStatus.selesai:
        return const Color(0xFF12B76A);
      case ServiceStatus.diambil:
        return const Color(0xFF101828);
    }
  }

  ServiceStatus? get next {
    switch (this) {
      case ServiceStatus.menunggu:
        return ServiceStatus.diagnosa;
      case ServiceStatus.diagnosa:
        return ServiceStatus.dikerjakan;
      case ServiceStatus.dikerjakan:
        return ServiceStatus.selesai;
      case ServiceStatus.selesai:
        return ServiceStatus.diambil;
      case ServiceStatus.diambil:
        return null;
    }
  }
}
