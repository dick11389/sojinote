import 'package:equatable/equatable.dart';

class NoteTag extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String color; // hex color code
  final DateTime createdAt;
  final int usageCount;

  const NoteTag({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.createdAt,
    required this.usageCount,
  });

  NoteTag copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    DateTime? createdAt,
    int? usageCount,
  }) {
    return NoteTag(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  @override
  List<Object?> get props => [id, name, description, color, createdAt, usageCount];
}

class NoteCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String icon; // emoji or icon name
  final DateTime createdAt;
  final int noteCount;

  const NoteCategory({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.createdAt,
    required this.noteCount,
  });

  NoteCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    DateTime? createdAt,
    int? noteCount,
  }) {
    return NoteCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      noteCount: noteCount ?? this.noteCount,
    );
  }

  @override
  List<Object?> get props => [id, name, description, icon, createdAt, noteCount];
}
