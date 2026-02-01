import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/bible_translation.dart';

abstract class TranslationRepository {
  Future<Either<Failure, List<BibleTranslation>>> getAvailableTranslations();
  Future<Either<Failure, bool>> setDefaultTranslation(String translationCode);
  Future<Either<Failure, bool>> downloadTranslation(String translationCode);
  Future<Either<Failure, Map<String, String>>> getVerseInMultipleTranslations(
    String reference,
    List<String> translationCodes,
  );
  Future<Either<Failure, BibleTranslation>> getDefaultTranslation();
  Future<Either<Failure, bool>> deleteDownloadedTranslation(String translationCode);
}
