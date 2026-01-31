import '../../core/usecases/usecase.dart';
import '../entities/bible_verse.dart';
import '../repositories/bible_repository.dart';

class GetVerse implements UseCase<BibleVerse, String> {
  final BibleRepository repository;

  GetVerse(this.repository);

  @override
  Future<BibleVerse> call(String params) async {
    return await repository.getVerse(params);
  }
}
