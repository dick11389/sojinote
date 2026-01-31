import '../../core/usecases/usecase.dart';
import '../repositories/note_repository.dart';

class DeleteNote implements UseCase<void, String> {
  final NoteRepository repository;

  DeleteNote(this.repository);

  @override
  Future<void> call(String params) async {
    return await repository.deleteNote(params);
  }
}
