import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/note_tag.dart';
import '../../domain/repositories/tag_category_repository.dart';

class CreateTag implements UseCase<NoteTag, CreateTagParams> {
  final TagCategoryRepository repository;

  CreateTag(this.repository);

  @override
  Future<Either<Failure, NoteTag>> call(CreateTagParams params) async {
    return await repository.createTag(params.name, params.color, params.description);
  }
}

class GetAllTags implements UseCase<List<NoteTag>, NoParams> {
  final TagCategoryRepository repository;

  GetAllTags(this.repository);

  @override
  Future<Either<Failure, List<NoteTag>>> call(NoParams params) async {
    return await repository.getAllTags();
  }
}

class DeleteTag implements UseCase<bool, String> {
  final TagCategoryRepository repository;

  DeleteTag(this.repository);

  @override
  Future<Either<Failure, bool>> call(String tagId) async {
    return await repository.deleteTag(tagId);
  }
}

class AddTagToNote implements UseCase<bool, AddTagToNoteParams> {
  final TagCategoryRepository repository;

  AddTagToNote(this.repository);

  @override
  Future<Either<Failure, bool>> call(AddTagToNoteParams params) async {
    return await repository.addTagToNote(params.noteId, params.tagId);
  }
}

class CreateCategory implements UseCase<NoteCategory, CreateCategoryParams> {
  final TagCategoryRepository repository;

  CreateCategory(this.repository);

  @override
  Future<Either<Failure, NoteCategory>> call(CreateCategoryParams params) async {
    return await repository.createCategory(params.name, params.icon, params.description);
  }
}

class GetAllCategories implements UseCase<List<NoteCategory>, NoParams> {
  final TagCategoryRepository repository;

  GetAllCategories(this.repository);

  @override
  Future<Either<Failure, List<NoteCategory>>> call(NoParams params) async {
    return await repository.getAllCategories();
  }
}

class SearchNotesByTag implements UseCase<List<String>, String> {
  final TagCategoryRepository repository;

  SearchNotesByTag(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(String tagId) async {
    return await repository.getNotesByTag(tagId);
  }
}

// Parameters
class CreateTagParams {
  final String name;
  final String color;
  final String? description;

  CreateTagParams({
    required this.name,
    required this.color,
    this.description,
  });
}

class AddTagToNoteParams {
  final String noteId;
  final String tagId;

  AddTagToNoteParams({required this.noteId, required this.tagId});
}

class CreateCategoryParams {
  final String name;
  final String icon;
  final String? description;

  CreateCategoryParams({
    required this.name,
    required this.icon,
    this.description,
  });
}
