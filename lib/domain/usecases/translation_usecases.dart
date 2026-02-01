import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/bible_translation.dart';
import '../../domain/repositories/translation_repository.dart';

class GetAvailableTranslations implements UseCase<List<BibleTranslation>, NoParams> {
  final TranslationRepository repository;

  GetAvailableTranslations(this.repository);

  @override
  Future<Either<Failure, List<BibleTranslation>>> call(NoParams params) async {
    return await repository.getAvailableTranslations();
  }
}

class SetDefaultTranslation implements UseCase<bool, String> {
  final TranslationRepository repository;

  SetDefaultTranslation(this.repository);

  @override
  Future<Either<Failure, bool>> call(String translationCode) async {
    return await repository.setDefaultTranslation(translationCode);
  }
}

class DownloadTranslation implements UseCase<bool, String> {
  final TranslationRepository repository;

  DownloadTranslation(this.repository);

  @override
  Future<Either<Failure, bool>> call(String translationCode) async {
    return await repository.downloadTranslation(translationCode);
  }
}

class GetVerseInMultipleTranslations
    implements UseCase<Map<String, String>, GetVerseMultiParams> {
  final TranslationRepository repository;

  GetVerseInMultipleTranslations(this.repository);

  @override
  Future<Either<Failure, Map<String, String>>> call(GetVerseMultiParams params) async {
    return await repository.getVerseInMultipleTranslations(
      params.reference,
      params.translationCodes,
    );
  }
}

class GetDefaultTranslation implements UseCase<BibleTranslation, NoParams> {
  final TranslationRepository repository;

  GetDefaultTranslation(this.repository);

  @override
  Future<Either<Failure, BibleTranslation>> call(NoParams params) async {
    return await repository.getDefaultTranslation();
  }
}

class DeleteDownloadedTranslation implements UseCase<bool, String> {
  final TranslationRepository repository;

  DeleteDownloadedTranslation(this.repository);

  @override
  Future<Either<Failure, bool>> call(String translationCode) async {
    return await repository.deleteDownloadedTranslation(translationCode);
  }
}

// Parameters
class GetVerseMultiParams {
  final String reference;
  final List<String> translationCodes;

  GetVerseMultiParams({
    required this.reference,
    required this.translationCodes,
  });
}
