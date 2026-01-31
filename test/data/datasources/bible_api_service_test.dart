import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sermon_notes/core/constants/api_constants.dart';
import 'package:sermon_notes/core/error/exceptions.dart';
import 'package:sermon_notes/data/datasources/bible_api_service.dart';
import 'package:sermon_notes/data/models/bible_verse_model.dart';

import 'bible_api_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late BibleApiServiceImpl service;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    service = BibleApiServiceImpl(client: mockClient);
  });

  group('BibleApiService - fetchVerseText', () {
    const testReference = 'John 3:16';
    final testUrl = Uri.parse('${ApiConstants.bibleApiBaseUrl}/John%203%3A16');

    test('should return BibleVerseModel when the API call is successful', () async {
      // Arrange
      const responseBody = '''
      {
        "reference": "John 3:16",
        "text": "For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.",
        "translation_id": "kjv",
        "translation_name": "King James Version"
      }
      ''';

      when(mockClient.get(testUrl))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await service.fetchVerseText(testReference);

      // Assert
      expect(result, isA<BibleVerseModel>());
      expect(result.reference, equals('John 3:16'));
      expect(result.book, equals('John'));
      expect(result.chapter, equals(3));
      expect(result.verse, equals(16));
      expect(result.text, contains('For God so loved the world'));
      verify(mockClient.get(testUrl)).called(1);
    });

    test('should throw NetworkException when there is no internet connection', () async {
      // Arrange
      when(mockClient.get(testUrl))
          .thenThrow(const SocketException('No internet'));

      // Act & Assert
      expect(
        () => service.fetchVerseText(testReference),
        throwsA(isA<NetworkException>().having(
          (e) => e.message,
          'message',
          ApiConstants.noInternetError,
        )),
      );
    });

    test('should throw NotFoundException when verse is not found (404)', () async {
      // Arrange
      when(mockClient.get(testUrl))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      // Act & Assert
      expect(
        () => service.fetchVerseText(testReference),
        throwsA(isA<NotFoundException>().having(
          (e) => e.message,
          'message',
          ApiConstants.verseNotFoundError,
        )),
      );
    });

    test('should throw NotFoundException when verse reference is invalid (400)', () async {
      // Arrange
      when(mockClient.get(testUrl))
          .thenAnswer((_) async => http.Response('Bad Request', 400));

      // Act & Assert
      expect(
        () => service.fetchVerseText(testReference),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('should throw ServerException when server returns 500 error', () async {
      // Arrange
      when(mockClient.get(testUrl))
          .thenAnswer((_) async => http.Response('Internal Server Error', 500));

      // Act & Assert
      expect(
        () => service.fetchVerseText(testReference),
        throwsA(isA<ServerException>().having(
          (e) => e.message,
          'message',
          ApiConstants.serverError,
        )),
      );
    });

    test('should throw NetworkException when request times out', () async {
      // Arrange
      when(mockClient.get(testUrl))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 35));
        return http.Response('', 200);
      });

      // Act & Assert
      expect(
        () => service.fetchVerseText(testReference),
        throwsA(isA<NetworkException>().having(
          (e) => e.message,
          'message',
          ApiConstants.timeoutError,
        )),
      );
    });

    test('should throw NotFoundException when response text is empty', () async {
      // Arrange
      const responseBody = '''
      {
        "reference": "John 3:16",
        "text": "",
        "translation_id": "kjv"
      }
      ''';

      when(mockClient.get(testUrl))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      // Act & Assert
      expect(
        () => service.fetchVerseText(testReference),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('should handle references with special characters correctly', () async {
      // Arrange
      const reference = '1 Corinthians 13:4-7';
      final encodedUrl = Uri.parse('${ApiConstants.bibleApiBaseUrl}/1%20Corinthians%2013%3A4-7');
      const responseBody = '''
      {
        "reference": "1 Corinthians 13:4-7",
        "text": "Charity suffereth long, and is kind...",
        "translation_id": "kjv"
      }
      ''';

      when(mockClient.get(encodedUrl))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await service.fetchVerseText(reference);

      // Assert
      expect(result.book, equals('1 Corinthians'));
      expect(result.chapter, equals(13));
      expect(result.verse, equals(4));
    });

    test('should clean and normalize reference with extra spaces', () async {
      // Arrange
      const messyReference = '  John   3:16  ';
      final cleanUrl = Uri.parse('${ApiConstants.bibleApiBaseUrl}/John%203%3A16');
      const responseBody = '''
      {
        "reference": "John 3:16",
        "text": "For God so loved the world...",
        "translation_id": "kjv"
      }
      ''';

      when(mockClient.get(cleanUrl))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await service.fetchVerseText(messyReference);

      // Assert
      expect(result.reference, equals('John 3:16'));
      verify(mockClient.get(cleanUrl)).called(1);
    });
  });

  group('BibleApiService - fetchMultipleVerses', () {
    test('should return list of BibleVerseModel for multiple references', () async {
      // Arrange
      final references = ['John 3:16', 'Romans 8:28'];
      
      when(mockClient.get(Uri.parse('${ApiConstants.bibleApiBaseUrl}/John%203%3A16')))
          .thenAnswer((_) async => http.Response('''
            {
              "reference": "John 3:16",
              "text": "For God so loved the world...",
              "translation_id": "kjv"
            }
          ''', 200));

      when(mockClient.get(Uri.parse('${ApiConstants.bibleApiBaseUrl}/Romans%208%3A28')))
          .thenAnswer((_) async => http.Response('''
            {
              "reference": "Romans 8:28",
              "text": "And we know that all things work together...",
              "translation_id": "kjv"
            }
          ''', 200));

      // Act
      final results = await service.fetchMultipleVerses(references);

      // Assert
      expect(results, hasLength(2));
      expect(results[0].book, equals('John'));
      expect(results[1].book, equals('Romans'));
    });

    test('should throw ServerException when all verses fail to fetch', () async {
      // Arrange
      final references = ['Invalid 1:1', 'Invalid 2:2'];
      
      when(mockClient.get(any))
          .thenThrow(const SocketException('No internet'));

      // Act & Assert
      expect(
        () => service.fetchMultipleVerses(references),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
