import '../../core/error/exceptions.dart';
import '../models/bible_verse_model.dart';
import 'bible_api_service.dart';

abstract class BibleRemoteDataSource {
  Future<BibleVerseModel> fetchVerse(String reference);
  Future<List<BibleVerseModel>> fetchMultipleVerses(List<String> references);
}

class BibleRemoteDataSourceImpl implements BibleRemoteDataSource {
  final BibleApiService apiService;

  BibleRemoteDataSourceImpl({required this.apiService});

  @override
  Future<BibleVerseModel> fetchVerse(String reference) async {
    try {
      return await apiService.fetchVerseText(reference);
    } catch (e) {
      if (e is NetworkException) {
        throw NetworkException(e.message);
      } else if (e is NotFoundException) {
        throw NotFoundException(e.message);
      } else if (e is ServerException) {
        throw ServerException(e.message);
      }
      throw ServerException('Failed to fetch verse: ${e.toString()}');
    }
  }

  @override
  Future<List<BibleVerseModel>> fetchMultipleVerses(List<String> references) async {
    try {
      return await apiService.fetchMultipleVerses(references);
    } catch (e) {
      if (e is NetworkException) {
        throw NetworkException(e.message);
      } else if (e is ServerException) {
        throw ServerException(e.message);
      }
      throw ServerException('Failed to fetch verses: ${e.toString()}');
    }
  }
}
