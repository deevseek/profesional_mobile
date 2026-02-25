import 'package:flutter/material.dart';

enum ServiceStatus { menunggu, dikerjakan, selesai, diambil, batal }

extension ServiceStatusX on ServiceStatus {
  static ServiceStatus fromRaw(String raw) {
    switch (raw.toLowerCase()) {
      case 'diagnosa':
      case 'diagnosis':
      case 'checking':
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
      case 'batal':
      case 'cancelled':
      case 'canceled':
        return ServiceStatus.batal;
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
      case ServiceStatus.dikerjakan:
        return 'in_progress';
      case ServiceStatus.selesai:
        return 'done';
      case ServiceStatus.diambil:
        return 'picked_up';
      case ServiceStatus.batal:
        return 'canceled';
    }
  }

  String get label {
    switch (this) {
      case ServiceStatus.menunggu:
        return 'Menunggu';
      case ServiceStatus.dikerjakan:
        return 'Dikerjakan';
      case ServiceStatus.selesai:
        return 'Selesai';
      case ServiceStatus.diambil:
        return 'Diambil';
      case ServiceStatus.batal:
        return 'Batal';
    }
  }

  Color get color {
    switch (this) {
      case ServiceStatus.menunggu:
        return const Color(0xFF98A2B3);
      case ServiceStatus.dikerjakan:
        return const Color(0xFFFF7A00);
      case ServiceStatus.selesai:
        return const Color(0xFF12B76A);
      case ServiceStatus.diambil:
        return const Color(0xFF101828);
      case ServiceStatus.batal:
        return const Color(0xFFD92D20);
    }
  }

  ServiceStatus? get next {
    switch (this) {
      case ServiceStatus.menunggu:
        return ServiceStatus.dikerjakan;
      case ServiceStatus.dikerjakan:
        return ServiceStatus.selesai;
      case ServiceStatus.selesai:
        return ServiceStatus.diambil;
      case ServiceStatus.diambil:
      case ServiceStatus.batal:
        return null;
    }
  }
}
