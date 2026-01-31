import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/bible_verse.dart';
import '../../domain/repositories/bible_repository.dart';
import '../datasources/bible_remote_datasource.dart';

class BibleRepositoryImpl implements BibleRepository {
  final BibleRemoteDataSource remoteDataSource;

  BibleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BibleVerse> getVerse(String reference) async {
    try {
      return await remoteDataSource.fetchVerse(reference);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on NotFoundException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw NetworkFailure('Failed to get verse: ${e.toString()}');
    }
  }

  @override
  List<String> detectVerseReferences(String text) {
    // Regex to detect Bible verse patterns like "John 3:16" or "1 Corinthians 13:4-7"
    final regex = RegExp(
      r'\b(\d\s)?([A-Z][a-z]+)\s(\d+):(\d+)(-\d+)?\b',
      caseSensitive: false,
    );
    
    final matches = regex.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

  @override
  Future<List<BibleVerse>> getMultipleVerses(List<String> references) async {
    try {
      return await remoteDataSource.fetchMultipleVerses(references);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw NetworkFailure('Failed to get verses: ${e.toString()}');
    }
  }
}
