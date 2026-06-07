import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<T> data;
  final Map<String, dynamic> meta;
  final Map<String, dynamic> links;

  int? get currentPage => _toInt(meta['current_page']);
  int? get lastPage => _toInt(meta['last_page']);
  int? get perPage => _toInt(meta['per_page']);
  int? get total => _toInt(meta['total']);

  bool get hasNextPage {
    final current = currentPage;
    final last = lastPage;

    if (current != null && last != null) {
      return current < last;
    }

    final nextFromMeta = meta['next_page_url'];
    if (nextFromMeta is String && nextFromMeta.isNotEmpty) {
      return true;
    }

    final nextFromLinks = links['next'];
    return nextFromLinks is String && nextFromLinks.isNotEmpty;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    return parseInt(value);
  }

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) fromJsonT,
  ) {
    final parsedData = unwrapDataList(json).map(fromJsonT).toList(growable: false);

    return PaginatedResponse<T>(
      data: parsedData,
      meta: parseMap(json['meta']),
      links: parseMap(json['links']),
    );
  }
}
