import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/note_tag.dart';
import '../../domain/repositories/tag_category_repository.dart';
import '../datasources/tag_category_datasource.dart';

class TagCategoryRepositoryImpl implements TagCategoryRepository {
  final TagCategoryLocalDatasource localDatasource;

  TagCategoryRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<Failure, NoteTag>> createTag(String name, String color, String? description) async {
    try {
      final tag = await localDatasource.createTag(name, color, description);
      return Right(tag);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<NoteTag>>> getAllTags() async {
    try {
      final tags = await localDatasource.getAllTags();
      return Right(tags);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTag(String tagId) async {
    try {
      await localDatasource.deleteTag(tagId);
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> addTagToNote(String noteId, String tagId) async {
    try {
      await localDatasource.addTagToNote(noteId, tagId);
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<String>>> getNotesByTag(String tagId) async {
    try {
      final notes = await localDatasource.getNotesByTag(tagId);
      return Right(notes);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, NoteCategory>> createCategory(String name, String icon, String? description) async {
    try {
      final category = await localDatasource.createCategory(name, icon, description);
      return Right(category);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<NoteCategory>>> getAllCategories() async {
    try {
      final categories = await localDatasource.getAllCategories();
      return Right(categories);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> setCategoryForNote(String noteId, String categoryId) async {
    try {
      await localDatasource.setCategoryForNote(noteId, categoryId);
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
