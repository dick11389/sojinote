import '../../domain/entities/highlighted_verse.dart';

class HighlightedVerseModel extends HighlightedVerse {
  const HighlightedVerseModel({
    required String id,
    required String noteId,
    required String reference,
    required String text,
    required String highlightColor,
    String? highlightNotes,
    required DateTime highlightedAt,
    required bool isStarred,
  }) : super(
    id: id,
    noteId: noteId,
    reference: reference,
    text: text,
    highlightColor: highlightColor,
    highlightNotes: highlightNotes,
    highlightedAt: highlightedAt,
    isStarred: isStarred,
  );

  factory HighlightedVerseModel.fromJson(Map<String, dynamic> json) {
    return HighlightedVerseModel(
      id: json['id'] as String,
      noteId: json['noteId'] as String,
      reference: json['reference'] as String,
      text: json['text'] as String,
      highlightColor: json['highlightColor'] as String,
      highlightNotes: json['highlightNotes'] as String?,
      highlightedAt: DateTime.parse(json['highlightedAt'] as String),
      isStarred: json['isStarred'] as bool,
    );
  }

  factory HighlightedVerseModel.fromDatabase(Map<String, dynamic> map) {
    return HighlightedVerseModel(
      id: map['id'] as String,
      noteId: map['noteId'] as String,
      reference: map['reference'] as String,
      text: map['text'] as String,
      highlightColor: map['highlightColor'] as String,
      highlightNotes: map['highlightNotes'] as String?,
      highlightedAt: DateTime.parse(map['highlightedAt'] as String),
      isStarred: map['isStarred'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'noteId': noteId,
    'reference': reference,
    'text': text,
    'highlightColor': highlightColor,
    'highlightNotes': highlightNotes,
    'highlightedAt': highlightedAt.toIso8601String(),
    'isStarred': isStarred,
  };

  Map<String, dynamic> toDatabase() => {
    'id': id,
    'noteId': noteId,
    'reference': reference,
    'text': text,
    'highlightColor': highlightColor,
    'highlightNotes': highlightNotes,
    'highlightedAt': highlightedAt.toIso8601String(),
    'isStarred': isStarred ? 1 : 0,
  };
}
