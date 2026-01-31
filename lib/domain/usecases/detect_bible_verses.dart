import '../../core/usecases/usecase.dart';
import '../repositories/bible_repository.dart';

class DetectBibleVerses implements UseCase<List<String>, String> {
  final BibleRepository repository;

  DetectBibleVerses(this.repository);

  @override
  Future<List<String>> call(String params) async {
    return repository.detectVerseReferences(params);
  }
}
