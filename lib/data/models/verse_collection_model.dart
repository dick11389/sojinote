import '../../domain/entities/verse_collection.dart';

class VerseCollectionModel extends VerseCollection {
  const VerseCollectionModel({
    required String id,
    required String name,
    String? description,
    required List<String> verseReferences,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? color,
    required bool isPublic,
    required int viewCount,
  }) : super(
    id: id,
    name: name,
    description: description,
    verseReferences: verseReferences,
    createdAt: createdAt,
    updatedAt: updatedAt,
    color: color,
    isPublic: isPublic,
    viewCount: viewCount,
  );

  factory VerseCollectionModel.fromJson(Map<String, dynamic> json) {
    return VerseCollectionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      verseReferences: List<String>.from(json['verseReferences'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      color: json['color'] as String?,
      isPublic: json['isPublic'] as bool,
      viewCount: json['viewCount'] as int,
    );
  }

  factory VerseCollectionModel.fromDatabase(Map<String, dynamic> map) {
    return VerseCollectionModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      verseReferences: (map['verseReferences'] as String?)
              ?.split(',')
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      color: map['color'] as String?,
      isPublic: map['isPublic'] == 1,
      viewCount: map['viewCount'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'verseReferences': verseReferences,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'color': color,
    'isPublic': isPublic,
    'viewCount': viewCount,
  };

  Map<String, dynamic> toDatabase() => {
    'id': id,
    'name': name,
    'description': description,
    'verseReferences': verseReferences.join(','),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'color': color,
    'isPublic': isPublic ? 1 : 0,
    'viewCount': viewCount,
  };
}
