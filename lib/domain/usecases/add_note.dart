import '../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class AddNote implements UseCase<void, Note> {
  final NoteRepository repository;

  AddNote(this.repository);

  @override
  Future<void> call(Note params) async {
    return await repository.addNote(params);
  }
}
