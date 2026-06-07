import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

class AppConfigModel {
  const AppConfigModel({
    required this.storeName,
    required this.logoUrl,
    required this.themeColor,
    required this.activeModules,
    required this.raw,
  });

  final String storeName;
  final String logoUrl;
  final String themeColor;
  final List<String> activeModules;
  final Map<String, dynamic> raw;

  static const defaultStoreName = 'Profesional Servis';

  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    final data = unwrapDataMap(json);
    final modules = data['modules'] ?? data['active_modules'];
    return AppConfigModel(
      storeName: parseString(data['store_name'] ?? data['tenant_name'] ?? data['name'], fallback: defaultStoreName),
      logoUrl: parseString(data['logo'] ?? data['logo_url'] ?? data['store_logo_path']),
      themeColor: parseString(data['theme_color'] ?? data['primary_color'], fallback: '#0B5FFF'),
      activeModules: modules is List ? modules.map(parseString).where((text) => text.isNotEmpty).toList(growable: false) : const <String>[],
      raw: data,
    );
  }
}
