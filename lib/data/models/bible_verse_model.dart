import '../../domain/entities/bible_verse.dart';

class BibleVerseModel extends BibleVerse {
  const BibleVerseModel({
    required super.reference,
    required super.text,
    required super.book,
    required super.chapter,
    required super.verse,
  });

  factory BibleVerseModel.fromJson(Map<String, dynamic> json) {
    // Parse the reference (e.g., "John 3:16")
    final reference = json['reference'] as String? ?? '';
    final parts = _parseReference(reference);
    
    return BibleVerseModel(
      reference: reference,
      text: _cleanText(json['text'] as String? ?? ''),
      book: parts['book'] ?? '',
      chapter: parts['chapter'] ?? 0,
      verse: parts['verse'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'text': text,
      'book': book,
      'chapter': chapter,
      'verse': verse,
    };
  }

  /// Parses a reference string like "John 3:16" into components
  static Map<String, dynamic> _parseReference(String reference) {
    try {
      // Pattern: "Book Chapter:Verse" or "1 Book Chapter:Verse"
      final pattern = RegExp(r'^((?:\d\s+)?[A-Za-z\s]+)\s+(\d+):(\d+)');
      final match = pattern.firstMatch(reference);
      
      if (match != null) {
        return {
          'book': match.group(1)?.trim() ?? '',
          'chapter': int.tryParse(match.group(2) ?? '') ?? 0,
          'verse': int.tryParse(match.group(3) ?? '') ?? 0,
        };
      }
    } catch (e) {
      // Return default values if parsing fails
    }
    
    return {
      'book': '',
      'chapter': 0,
      'verse': 0,
    };
  }

  /// Cleans the text by removing extra whitespace and formatting
  static String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces with single space
        .trim();
  }

  BibleVerseModel copyWith({
    String? reference,
    String? text,
    String? book,
    int? chapter,
    int? verse,
  }) {
    return BibleVerseModel(
      reference: reference ?? this.reference,
      text: text ?? this.text,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
    );
  }
}
