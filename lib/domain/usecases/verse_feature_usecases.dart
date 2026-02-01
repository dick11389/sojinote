import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/highlighted_verse.dart';
import '../../domain/entities/verse_collection.dart';
import '../../domain/repositories/verse_repository.dart';

class HighlightVerse implements UseCase<HighlightedVerse, HighlightVerseParams> {
  final VerseRepository repository;

  HighlightVerse(this.repository);

  @override
  Future<Either<Failure, HighlightedVerse>> call(HighlightVerseParams params) async {
    return await repository.highlightVerse(
      params.noteId,
      params.reference,
      params.text,
      params.color,
      params.notes,
    );
  }
}

class GetHighlightedVerses implements UseCase<List<HighlightedVerse>, String> {
  final VerseRepository repository;

  GetHighlightedVerses(this.repository);

  @override
  Future<Either<Failure, List<HighlightedVerse>>> call(String noteId) async {
    return await repository.getHighlightedVerses(noteId);
  }
}

class RemoveHighlight implements UseCase<bool, String> {
  final VerseRepository repository;

  RemoveHighlight(this.repository);

  @override
  Future<Either<Failure, bool>> call(String highlightId) async {
    return await repository.removeHighlight(highlightId);
  }
}

class CreateVerseCollection implements UseCase<VerseCollection, CreateCollectionParams> {
  final VerseRepository repository;

  CreateVerseCollection(this.repository);

  @override
  Future<Either<Failure, VerseCollection>> call(CreateCollectionParams params) async {
    return await repository.createVerseCollection(
      params.name,
      params.verseReferences,
      params.description,
      params.color,
      params.isPublic,
    );
  }
}

class GetVerseCollections implements UseCase<List<VerseCollection>, NoParams> {
  final VerseRepository repository;

  GetVerseCollections(this.repository);

  @override
  Future<Either<Failure, List<VerseCollection>>> call(NoParams params) async {
    return await repository.getVerseCollections();
  }
}

class AddVerseToCollection implements UseCase<bool, AddVerseToCollectionParams> {
  final VerseRepository repository;

  AddVerseToCollection(this.repository);

  @override
  Future<Either<Failure, bool>> call(AddVerseToCollectionParams params) async {
    return await repository.addVerseToCollection(params.collectionId, params.verseReference);
  }
}

class ShareVerseCollection implements UseCase<String, String> {
  final VerseRepository repository;

  ShareVerseCollection(this.repository);

  @override
  Future<Either<Failure, String>> call(String collectionId) async {
    return await repository.shareVerseCollection(collectionId);
  }
}

// Parameters
class HighlightVerseParams {
  final String noteId;
  final String reference;
  final String text;
  final String color;
  final String? notes;

  HighlightVerseParams({
    required this.noteId,
    required this.reference,
    required this.text,
    required this.color,
    this.notes,
  });
}

class CreateCollectionParams {
  final String name;
  final List<String> verseReferences;
  final String? description;
  final String? color;
  final bool isPublic;

  CreateCollectionParams({
    required this.name,
    required this.verseReferences,
    this.description,
    this.color,
    required this.isPublic,
  });
}

class AddVerseToCollectionParams {
  final String collectionId;
  final String verseReference;

  AddVerseToCollectionParams({
    required this.collectionId,
    required this.verseReference,
  });
}
