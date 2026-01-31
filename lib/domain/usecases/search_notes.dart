import '../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class SearchNotes implements UseCase<List<Note>, String> {
  final NoteRepository repository;

  SearchNotes(this.repository);

  @override
  Future<List<Note>> call(String params) async {
    return await repository.searchNotes(params);
  }
}
