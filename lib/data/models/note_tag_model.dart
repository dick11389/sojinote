import '../../domain/entities/note_tag.dart';

class NoteTagModel extends NoteTag {
  const NoteTagModel({
    required String id,
    required String name,
    String? description,
    required String color,
    required DateTime createdAt,
    required int usageCount,
  }) : super(
    id: id,
    name: name,
    description: description,
    color: color,
    createdAt: createdAt,
    usageCount: usageCount,
  );

  factory NoteTagModel.fromJson(Map<String, dynamic> json) {
    return NoteTagModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      usageCount: json['usageCount'] as int,
    );
  }

  factory NoteTagModel.fromDatabase(Map<String, dynamic> map) {
    return NoteTagModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      color: map['color'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      usageCount: map['usageCount'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'color': color,
    'createdAt': createdAt.toIso8601String(),
    'usageCount': usageCount,
  };

  Map<String, dynamic> toDatabase() => {
    'id': id,
    'name': name,
    'description': description,
    'color': color,
    'createdAt': createdAt.toIso8601String(),
    'usageCount': usageCount,
  };
}

class NoteCategoryModel extends NoteCategory {
  const NoteCategoryModel({
    required String id,
    required String name,
    String? description,
    required String icon,
    required DateTime createdAt,
    required int noteCount,
  }) : super(
    id: id,
    name: name,
    description: description,
    icon: icon,
    createdAt: createdAt,
    noteCount: noteCount,
  );

  factory NoteCategoryModel.fromJson(Map<String, dynamic> json) {
    return NoteCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      noteCount: json['noteCount'] as int,
    );
  }

  factory NoteCategoryModel.fromDatabase(Map<String, dynamic> map) {
    return NoteCategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      icon: map['icon'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      noteCount: map['noteCount'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'createdAt': createdAt.toIso8601String(),
    'noteCount': noteCount,
  };

  Map<String, dynamic> toDatabase() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'createdAt': createdAt.toIso8601String(),
    'noteCount': noteCount,
  };
}
