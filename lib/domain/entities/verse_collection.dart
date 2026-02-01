import 'package:equatable/equatable.dart';

class VerseCollection extends Equatable {
  final String id;
  final String name;
  final String? description;
  final List<String> verseReferences; // list of 'John 3:16' style refs
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? color;
  final bool isPublic;
  final int viewCount;

  const VerseCollection({
    required this.id,
    required this.name,
    this.description,
    required this.verseReferences,
    required this.createdAt,
    this.updatedAt,
    this.color,
    required this.isPublic,
    required this.viewCount,
  });

  VerseCollection copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? verseReferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? color,
    bool? isPublic,
    int? viewCount,
  }) {
    return VerseCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      verseReferences: verseReferences ?? this.verseReferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
      isPublic: isPublic ?? this.isPublic,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    verseReferences,
    createdAt,
    updatedAt,
    color,
    isPublic,
    viewCount,
  ];
}
