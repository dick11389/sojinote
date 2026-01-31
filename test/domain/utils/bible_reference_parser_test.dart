import 'package:flutter_test/flutter_test.dart';
import 'package:sermon_notes/domain/utils/bible_reference_parser.dart';
import 'package:sermon_notes/domain/entities/bible_reference.dart';

void main() {
  group('BibleReferenceParser', () {
    test('should parse simple verse reference with colon separator', () {
      // Arrange
      const text = 'Today we read John 3:16 in church.';

      // Act
      final results = BibleReferenceParser.parse(text);

      // Assert
      expect(results, hasLength(1));
      expect(results[0].book, equals('John'));
      expect(results[0].chapter, equals(3));
      expect(results[0].startVerse, equals(16));
      expect(results[0].endVerse, equals(16));
      expect(results[0].originalText, equals('John 3:16'));
    });

    test('should parse verse reference with verse range', () {
      // Arrange
      const text = 'Read John 3:16-17 for more context.';

      // Act
      final results = BibleReferenceParser.parse(text);

      // Assert
      expect(results, hasLength(1));
      expect(results[0].book, equals('John'));
      expect(results[0].chapter, equals(3));
      expect(results[0].startVerse, equals(16));
      expect(results[0].endVerse, equals(17));
      expect(results[0].isVerseRange, isTrue);
    });

    test('should parse verse reference with "vs" separator', () {
      // Arrange
      const text = 'Check out Gen 1vs1 and Gen 2vs3-5.';

      // Act
      final results = BibleReferenceParser.parse(text);

      // Assert
      expect(results, hasLength(2));
      
      expect(results[0].book, equals('Genesis'));
      expect(results[0].chapter, equals(1));
      expect(results[0].startVerse, equals(1));
      
      expect(results[1].book, equals('Genesis'));
      expect(results[1].chapter, equals(2));
      expect(results[1].startVerse, equals(3));
      expect(results[1].endVerse, equals(5));
    });

    test('should parse numbered book references', () {
      // Arrange
      const text = 'See 1 Cor 13:4-7 and 2 Kings 4vs12 for wisdom.';

      // Act
      final results = BibleReferenceParser.parse(text);

      // Assert
      expect(results, hasLength(2));
      
      expect(results[0].book, equals('1 Corinthians'));
      expect(results[0].chapter, equals(13));
      expect(results[0].startVerse, equals(4));
      expect(results[0].endVerse, equals(7));
      
      expect(results[1].book, equals('2 Kings'));
      expect(results[1].chapter, equals(4));
      expect(results[1].startVerse, equals(12));
    });

    test('should parse chapter-only references', () {
      // Arrange
      const text = 'The entire 1 Cor 13 is about love.';

      // Act
      final results = BibleReferenceParser.parse(text);

      // Assert
      expect(results, hasLength(1));
      expect(results[0].book, equals('1 Corinthians'));
      expect(results[0].chapter, equals(13));
      expect(results[0].startVerse, isNull);
      expect(results[0].endVerse, isNull);
      expect(results[0].isChapterOnly, isTrue);
    });

    test('should NOT parse names without chapter/verse numbers', () {
      // Arrange
      const text = 'Mark said hello to John yesterday. James walked by.';

      // Act
      final results = BibleReferenceParser.parse(text);

      // Assert
      expect(results, isEmpty);
    });

    test('should NOT parse lowercase book names', () {
      // Arrange
      const text = 'I read john 3:16 today.';

      // Act
      final results = BibleReferenceParser.parse(text);

      // Assert
      expect(results, isEmpty);
    });

    test('should parse multiple references in the same text', () {
      // Arrange
      const text = '''
        Today's sermon covered Gen 1:1, John 3:16-17, 
        and the whole chapter of Romans 8. Don't forget Psalm 23:1!
      ''';

      // Act
      final results = BibleReferenceParser.parse(text);

      // Assert
      expect(results, hasLength(4));
      
      expect(results[0].book, equals('Genesis'));
      expect(results[0].chapter, equals(1));
      expect(results[0].startVerse, equals(1));
      
      expect(results[1].book, equals('John'));
      expect(results[1].chapter, equals(3));
      expect(results[1].startVerse, equals(16));
      expect(results[1].endVerse, equals(17));
      
      expect(results[2].book, equals('Romans'));
      expect(results[2].chapter, equals(8));
      expect(results[2].isChapterOnly, isTrue);
      
      expect(results[3].book, equals('Psalms'));
      expect(results[3].chapter, equals(23));
      expect(results[3].startVerse, equals(1));
    });

    test('should parse abbreviated book names correctly', () {
      // Arrange
      const text = 'Read Matt 5:3-12 and Phil 4:13.';

      // Act
      final results = BibleReferenceParser.parse(text);

      // Assert
      expect(results, hasLength(2));
      
      expect(results[0].book, equals('Matthew'));
      expect(results[0].chapter, equals(5));
      expect(results[0].startVerse, equals(3));
      expect(results[0].endVerse, equals(12));
      
      expect(results[1].book, equals('Philippians'));
      expect(results[1].chapter, equals(4));
      expect(results[1].startVerse, equals(13));
    });

    test('should handle edge cases with punctuation', () {
      // Arrange
      const text = 'References: Gen 1:1, John 3:16; Rom 8:28.';

      // Act
      final results = BibleReferenceParser.parse(text);

      // Assert
      expect(results, hasLength(3));
      expect(results[0].book, equals('Genesis'));
      expect(results[1].book, equals('John'));
      expect(results[2].book, equals('Romans'));
    });

    test('should validate formatted output', () {
      // Arrange
      const text = 'See John 3:16-18 and Rom 8 today.';

      // Act
      final results = BibleReferenceParser.parse(text);

      // Assert
      expect(results[0].formatted, equals('John 3:16-18'));
      expect(results[1].formatted, equals('Romans 8'));
    });

    test('should recognize valid book names', () {
      // Act & Assert
      expect(BibleReferenceParser.isValidBookName('John'), isTrue);
      expect(BibleReferenceParser.isValidBookName('1 Corinthians'), isTrue);
      expect(BibleReferenceParser.isValidBookName('Genesis'), isTrue);
      expect(BibleReferenceParser.isValidBookName('Matt'), isTrue);
      expect(BibleReferenceParser.isValidBookName('InvalidBook'), isFalse);
      expect(BibleReferenceParser.isValidBookName('Mark'), isTrue);
      expect(BibleReferenceParser.isValidBookName('James'), isTrue);
    });

    test('should NOT confuse common names with book references when no numbers present', () {
      // Arrange
      const text = '''
        Mark told me that John was coming.
        James said hello and Peter agreed.
        Timothy walked with Paul yesterday.
      ''';

      // Act
      final results = BibleReferenceParser.parse(text);

      // Assert
      expect(results, isEmpty, 
        reason: 'Should not match names without chapter/verse numbers');
    });
  });
}
