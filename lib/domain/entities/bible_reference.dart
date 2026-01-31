import 'package:equatable/equatable.dart';

class BibleReference extends Equatable {
  final String book;
  final int chapter;
  final int? startVerse;
  final int? endVerse;
  final String originalText;

  const BibleReference({
    required this.book,
    required this.chapter,
    this.startVerse,
    this.endVerse,
    required this.originalText,
  });

  /// Returns true if this is a chapter-only reference (no verses)
  bool get isChapterOnly => startVerse == null && endVerse == null;

  /// Returns true if this is a verse range (has both start and end verses)
  bool get isVerseRange => startVerse != null && endVerse != null && startVerse != endVerse;

  /// Returns a formatted reference string (e.g., "John 3:16" or "John 3:16-17")
  String get formatted {
    if (isChapterOnly) {
      return '$book $chapter';
    } else if (isVerseRange) {
      return '$book $chapter:$startVerse-$endVerse';
    } else {
      return '$book $chapter:$startVerse';
    }
  }

  @override
  List<Object?> get props => [book, chapter, startVerse, endVerse, originalText];

  @override
  String toString() => formatted;
}
