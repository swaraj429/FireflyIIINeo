import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    String? icon,
    String? color,
    String? parentId,
    @Default(0) int order,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}

class CreateCategoryRequest {
  final String name;
  final String? icon;
  final String? color;
  final String? parentId;
  final int order;

  const CreateCategoryRequest({
    required this.name,
    this.icon,
    this.color,
    this.parentId,
    this.order = 0,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        if (parentId != null) 'parent_id': parentId,
        'order': order,
      };
}

class UpdateCategoryRequest {
  final String? name;
  final String? icon;
  final String? color;
  final String? parentId;
  final int? order;

  const UpdateCategoryRequest({
    this.name,
    this.icon,
    this.color,
    this.parentId,
    this.order,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (icon != null) map['icon'] = icon;
    if (color != null) map['color'] = color;
    if (parentId != null) map['parent_id'] = parentId;
    if (order != null) map['order'] = order;
    return map;
  }
}
