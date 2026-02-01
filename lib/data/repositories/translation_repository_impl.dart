import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/bible_translation.dart';
import '../../domain/repositories/translation_repository.dart';
import '../datasources/translation_datasource.dart';
import '../datasources/bible_api_service.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationDatasource datasource;
  final BibleApiService apiService;

  TranslationRepositoryImpl({
    required this.datasource,
    required this.apiService,
  });

  @override
  Future<Either<Failure, List<BibleTranslation>>> getAvailableTranslations() async {
    try {
      final translations = await datasource.getAvailableTranslations();
      return Right(translations);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> setDefaultTranslation(String translationCode) async {
    try {
      await datasource.setDefaultTranslation(translationCode);
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> downloadTranslation(String translationCode) async {
    try {
      // Implement translation download from API or backend
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> getVerseInMultipleTranslations(
    String reference,
    List<String> translationCodes,
  ) async {
    try {
      final results = <String, String>{};
      
      for (final code in translationCodes) {
        final translation = await datasource.getTranslationByCode(code);
        if (translation != null) {
          // Fetch verse from API or local storage
          final verse = 'Verse text for $reference in $code';
          results[code] = verse;
        }
      }
      
      return Right(results);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, BibleTranslation>> getDefaultTranslation() async {
    try {
      final translation = await datasource.getDefaultTranslation();
      if (translation != null) {
        return Right(translation);
      }
      return Left(NotFoundFailure());
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDownloadedTranslation(String translationCode) async {
    try {
      await datasource.deleteTranslation(translationCode);
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
