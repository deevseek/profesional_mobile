import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

class ApiResponse<T> {
  const ApiResponse({required this.data, this.message = ''});

  final T data;
  final String message;

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic value) parser) {
    return ApiResponse<T>(
      data: parser(json.containsKey('data') ? json['data'] : json),
      message: parseString(json['message']),
    );
  }
}
