import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/highlighted_verse.dart';
import '../entities/verse_collection.dart';

abstract class VerseRepository {
  Future<Either<Failure, HighlightedVerse>> highlightVerse(
    String noteId,
    String reference,
    String text,
    String color,
    String? notes,
  );
  Future<Either<Failure, List<HighlightedVerse>>> getHighlightedVerses(String noteId);
  Future<Either<Failure, bool>> removeHighlight(String highlightId);
  
  Future<Either<Failure, VerseCollection>> createVerseCollection(
    String name,
    List<String> verseReferences,
    String? description,
    String? color,
    bool isPublic,
  );
  Future<Either<Failure, List<VerseCollection>>> getVerseCollections();
  Future<Either<Failure, bool>> addVerseToCollection(String collectionId, String verseReference);
  Future<Either<Failure, String>> shareVerseCollection(String collectionId);
}
