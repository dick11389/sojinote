import 'package:equatable/equatable.dart';

class HighlightedVerse extends Equatable {
  final String id;
  final String noteId;
  final String reference;
  final String text;
  final String highlightColor; // hex color
  final String? highlightNotes;
  final DateTime highlightedAt;
  final bool isStarred;

  const HighlightedVerse({
    required this.id,
    required this.noteId,
    required this.reference,
    required this.text,
    required this.highlightColor,
    this.highlightNotes,
    required this.highlightedAt,
    required this.isStarred,
  });

  HighlightedVerse copyWith({
    String? id,
    String? noteId,
    String? reference,
    String? text,
    String? highlightColor,
    String? highlightNotes,
    DateTime? highlightedAt,
    bool? isStarred,
  }) {
    return HighlightedVerse(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      reference: reference ?? this.reference,
      text: text ?? this.text,
      highlightColor: highlightColor ?? this.highlightColor,
      highlightNotes: highlightNotes ?? this.highlightNotes,
      highlightedAt: highlightedAt ?? this.highlightedAt,
      isStarred: isStarred ?? this.isStarred,
    );
  }

  @override
  List<Object?> get props => [
    id,
    noteId,
    reference,
    text,
    highlightColor,
    highlightNotes,
    highlightedAt,
    isStarred,
  ];
}
