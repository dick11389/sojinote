import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/highlighted_verse.dart';
import '../../domain/entities/verse_collection.dart';
import '../../domain/repositories/verse_repository.dart';
import '../datasources/verse_datasource.dart';

class VerseRepositoryImpl implements VerseRepository {
  final VerseDatasource datasource;

  VerseRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, HighlightedVerse>> highlightVerse(
    String noteId,
    String reference,
    String text,
    String color,
    String? notes,
  ) async {
    try {
      final verse = await datasource.highlightVerse(noteId, reference, text, color, notes);
      return Right(verse);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<HighlightedVerse>>> getHighlightedVerses(String noteId) async {
    try {
      final verses = await datasource.getHighlightedVerses(noteId);
      return Right(verses);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> removeHighlight(String highlightId) async {
    try {
      await datasource.removeHighlight(highlightId);
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, VerseCollection>> createVerseCollection(
    String name,
    List<String> verseReferences,
    String? description,
    String? color,
    bool isPublic,
  ) async {
    try {
      final collection = await datasource.createVerseCollection(
        name,
        verseReferences,
        description,
        color,
        isPublic,
      );
      return Right(collection);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<VerseCollection>>> getVerseCollections() async {
    try {
      final collections = await datasource.getVerseCollections();
      return Right(collections);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> addVerseToCollection(String collectionId, String verseReference) async {
    try {
      await datasource.addVerseToCollection(collectionId, verseReference);
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String>> shareVerseCollection(String collectionId) async {
    try {
      // Generate shareable link or QR code
      final shareLink = 'https://sermonotes.app/collection/$collectionId';
      return Right(shareLink);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
