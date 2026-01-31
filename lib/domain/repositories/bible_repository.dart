import '../entities/bible_verse.dart';

abstract class BibleRepository {
  Future<BibleVerse> getVerse(String reference);
  Future<List<BibleVerse>> getMultipleVerses(List<String> references);
  List<String> detectVerseReferences(String text);
}
