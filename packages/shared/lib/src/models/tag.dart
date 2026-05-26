import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

@freezed
class Tag with _$Tag {
  const factory Tag({
    required String id,
    required String name,
    String? color,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}

class CreateTagRequest {
  final String name;
  final String? color;
  final String? description;

  const CreateTagRequest({
    required this.name,
    this.color,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (color != null) 'color': color,
        if (description != null) 'description': description,
      };
}
