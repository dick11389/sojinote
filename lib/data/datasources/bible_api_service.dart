import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../models/bible_verse_model.dart';

abstract class BibleApiService {
  /// Fetches the verse text for a given Bible reference
  /// 
  /// [reference] - The Bible reference (e.g., "John 3:16", "Genesis 1:1")
  /// 
  /// Returns a [BibleVerseModel] containing the verse text and metadata
  /// 
  /// Throws:
  /// - [NetworkException] if there's no internet connection
  /// - [NotFoundException] if the verse is not found
  /// - [ServerException] for other API errors
  Future<BibleVerseModel> fetchVerseText(String reference);

  /// Fetches multiple verses at once
  /// 
  /// [references] - List of Bible references
  /// 
  /// Returns a list of [BibleVerseModel] objects
  Future<List<BibleVerseModel>> fetchMultipleVerses(List<String> references);
}

class BibleApiServiceImpl implements BibleApiService {
  final http.Client client;

  BibleApiServiceImpl({required this.client});

  @override
  Future<BibleVerseModel> fetchVerseText(String reference) async {
    try {
      // Clean and encode the reference for URL
      final cleanReference = _cleanReference(reference);
      final encodedReference = Uri.encodeComponent(cleanReference);
      final url = Uri.parse('${ApiConstants.bibleApiBaseUrl}/$encodedReference');

      // Make the API request with timeout
      final response = await client
          .get(url)
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw TimeoutException(ApiConstants.timeoutError);
            },
          );

      return _handleResponse(response);
    } on SocketException catch (_) {
      throw NetworkException(ApiConstants.noInternetError);
    } on TimeoutException catch (_) {
      throw NetworkException(ApiConstants.timeoutError);
    } on HttpException catch (_) {
      throw NetworkException(ApiConstants.noInternetError);
    } on FormatException catch (_) {
      throw ServerException('Invalid response format from server');
    } catch (e) {
      if (e is NetworkException || e is NotFoundException || e is ServerException) {
        rethrow;
      }
      throw ServerException('${ApiConstants.unknownError}: ${e.toString()}');
    }
  }

  @override
  Future<List<BibleVerseModel>> fetchMultipleVerses(List<String> references) async {
    final List<BibleVerseModel> verses = [];
    final List<String> errors = [];

    for (final reference in references) {
      try {
        final verse = await fetchVerseText(reference);
        verses.add(verse);
      } catch (e) {
        errors.add('Error fetching $reference: ${e.toString()}');
      }
    }

    if (verses.isEmpty && errors.isNotEmpty) {
      throw ServerException('Failed to fetch any verses: ${errors.join(', ')}');
    }

    return verses;
  }

  /// Handles the HTTP response and converts it to a BibleVerseModel
  BibleVerseModel _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        try {
          final jsonData = json.decode(response.body) as Map<String, dynamic>;
          
          // Check if the verse was found
          if (jsonData['text'] == null || (jsonData['text'] as String).isEmpty) {
            throw NotFoundException(ApiConstants.verseNotFoundError);
          }
          
          return BibleVerseModel.fromJson(jsonData);
        } catch (e) {
          if (e is NotFoundException) rethrow;
          throw ServerException('Failed to parse response: ${e.toString()}');
        }

      case 404:
        throw NotFoundException(ApiConstants.verseNotFoundError);

      case 400:
        throw NotFoundException('Invalid Bible reference format');

      case 500:
      case 502:
      case 503:
      case 504:
        throw ServerException(ApiConstants.serverError);

      default:
        throw ServerException(
          'Server error with status code: ${response.statusCode}',
        );
    }
  }

  /// Cleans the reference by removing extra spaces and normalizing format
  String _cleanReference(String reference) {
    return reference.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
