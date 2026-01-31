import '../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class GetNoteById implements UseCase<Note, String> {
  final NoteRepository repository;

  GetNoteById(this.repository);

  @override
  Future<Note> call(String params) async {
    return await repository.getNoteById(params);
  }
}
