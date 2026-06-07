DateTime? parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    final millis = value > 100000000000 ? value : value * 1000;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

int parseInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final text = value.toString().trim();
  if (text.isEmpty) return fallback;
  return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? fallback;
}

double parseDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  final text = value.toString().trim().replaceAll(',', '');
  if (text.isEmpty) return fallback;
  return double.tryParse(text) ?? fallback;
}

String parseString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

bool parseBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().trim().toLowerCase();
  if (text.isEmpty) return fallback;
  return ['1', 'true', 'yes', 'y', 'active', 'enabled'].contains(text);
}

Map<String, dynamic> parseMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, val) => MapEntry(key.toString(), val));
  return <String, dynamic>{};
}

List<Map<String, dynamic>> parseMapList(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value.map(parseMap).where((item) => item.isNotEmpty).toList(growable: false);
}

Map<String, dynamic> unwrapDataMap(Map<String, dynamic>? body) {
  if (body == null) return <String, dynamic>{};
  final data = body['data'];
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return parseMap(data);
  return body;
}

List<Map<String, dynamic>> unwrapDataList(Map<String, dynamic>? body) {
  if (body == null) return const <Map<String, dynamic>>[];
  final data = body['data'];
  if (data is List) return parseMapList(data);
  if (body['items'] is List) return parseMapList(body['items']);
  return const <Map<String, dynamic>>[];
}
