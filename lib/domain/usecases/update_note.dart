import '../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class UpdateNote implements UseCase<void, Note> {
  final NoteRepository repository;

  UpdateNote(this.repository);

  @override
  Future<void> call(Note params) async {
    return await repository.updateNote(params);
  }
}
