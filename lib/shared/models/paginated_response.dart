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
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) fromJsonT,
  ) {
    final rawData = json['data'];
    final parsedData = rawData is List
        ? rawData
              .whereType<Map<String, dynamic>>()
              .map(fromJsonT)
              .toList(growable: false)
        : <T>[];

    return PaginatedResponse<T>(
      data: parsedData,
      meta: (json['meta'] is Map<String, dynamic>)
          ? json['meta'] as Map<String, dynamic>
          : <String, dynamic>{},
      links: (json['links'] is Map<String, dynamic>)
          ? json['links'] as Map<String, dynamic>
          : <String, dynamic>{},
    );
  }
}
