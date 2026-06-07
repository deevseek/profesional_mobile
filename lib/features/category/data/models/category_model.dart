import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

class CategoryModel {
  const CategoryModel({required this.id, required this.name, required this.description});
  final String id;
  final String name;
  final String description;
  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(id: parseString(json['id']), name: parseString(json['name'], fallback: '-'), description: parseString(json['description']));
  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}
