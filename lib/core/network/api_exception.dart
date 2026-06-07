import 'package:dio/dio.dart';
import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.errors = const <String, List<String>>{},
  });

  final int? statusCode;
  final String message;
  final Map<String, List<String>> errors;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isValidation => statusCode == 422;

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final body = parseMap(response?.data);
    final message = _messageFor(statusCode, body, error);
    return ApiException(
      statusCode: statusCode,
      message: message,
      errors: _validationErrors(body['errors']),
    );
  }

  static String _messageFor(int? statusCode, Map<String, dynamic> body, DioException error) {
    final apiMessage = parseString(body['message']);
    if (apiMessage.isNotEmpty) return apiMessage;

    switch (statusCode) {
      case 401:
        return 'Sesi login berakhir. Silakan login ulang.';
      case 403:
        return 'Anda tidak memiliki akses ke fitur ini.';
      case 404:
        return 'Data tidak ditemukan.';
      case 422:
        return 'Data belum valid. Periksa kembali input Anda.';
      case 500:
        return 'Server sedang bermasalah. Coba beberapa saat lagi.';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Koneksi bermasalah. Periksa internet Anda.';
    }

    return 'Terjadi kesalahan. Coba lagi.';
  }

  static Map<String, List<String>> _validationErrors(dynamic value) {
    final raw = parseMap(value);
    return raw.map((key, val) {
      if (val is List) return MapEntry(key, val.map(parseString).where((text) => text.isNotEmpty).toList());
      final text = parseString(val);
      return MapEntry(key, text.isEmpty ? const <String>[] : <String>[text]);
    });
  }

  @override
  String toString() => message;
}
