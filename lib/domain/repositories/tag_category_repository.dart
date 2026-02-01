import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/note_tag.dart';

abstract class TagCategoryRepository {
  Future<Either<Failure, NoteTag>> createTag(String name, String color, String? description);
  Future<Either<Failure, List<NoteTag>>> getAllTags();
  Future<Either<Failure, bool>> deleteTag(String tagId);
  Future<Either<Failure, bool>> addTagToNote(String noteId, String tagId);
  Future<Either<Failure, List<String>>> getNotesByTag(String tagId);
  
  Future<Either<Failure, NoteCategory>> createCategory(String name, String icon, String? description);
  Future<Either<Failure, List<NoteCategory>>> getAllCategories();
  Future<Either<Failure, bool>> setCategoryForNote(String noteId, String categoryId);
}
