import 'package:sqflite/sqflite.dart';
import '../../domain/entities/highlighted_verse.dart';
import '../../domain/entities/verse_collection.dart';
import '../models/highlighted_verse_model.dart';
import '../models/verse_collection_model.dart';

abstract class VerseDatasource {
  Future<HighlightedVerseModel> highlightVerse(
    String noteId,
    String reference,
    String text,
    String color,
    String? notes,
  );
  Future<List<HighlightedVerseModel>> getHighlightedVerses(String noteId);
  Future<void> removeHighlight(String highlightId);
  
  Future<VerseCollectionModel> createVerseCollection(
    String name,
    List<String> verseReferences,
    String? description,
    String? color,
    bool isPublic,
  );
  Future<List<VerseCollectionModel>> getVerseCollections();
  Future<void> addVerseToCollection(String collectionId, String verseReference);
}

class VerseDatasourceImpl implements VerseDatasource {
  final Database database;

  VerseDatasourceImpl({required this.database});

  @override
  Future<HighlightedVerseModel> highlightVerse(
    String noteId,
    String reference,
    String text,
    String color,
    String? notes,
  ) async {
    final verseId = 'verse_${DateTime.now().millisecondsSinceEpoch}';
    final verse = HighlightedVerseModel(
      id: verseId,
      noteId: noteId,
      reference: reference,
      text: text,
      highlightColor: color,
      highlightNotes: notes,
      highlightedAt: DateTime.now(),
      isStarred: false,
    );
    await database.insert('highlighted_verses', verse.toDatabase());
    return verse;
  }

  @override
  Future<List<HighlightedVerseModel>> getHighlightedVerses(String noteId) async {
    final result = await database.query(
      'highlighted_verses',
      where: 'noteId = ?',
      whereArgs: [noteId],
      orderBy: 'highlightedAt DESC',
    );
    return result.map((map) => HighlightedVerseModel.fromDatabase(map)).toList();
  }

  @override
  Future<void> removeHighlight(String highlightId) async {
    await database.delete(
      'highlighted_verses',
      where: 'id = ?',
      whereArgs: [highlightId],
    );
  }

  @override
  Future<VerseCollectionModel> createVerseCollection(
    String name,
    List<String> verseReferences,
    String? description,
    String? color,
    bool isPublic,
  ) async {
    final collectionId = 'coll_${DateTime.now().millisecondsSinceEpoch}';
    final collection = VerseCollectionModel(
      id: collectionId,
      name: name,
      verseReferences: verseReferences,
      description: description,
      createdAt: DateTime.now(),
      color: color,
      isPublic: isPublic,
      viewCount: 0,
    );
    await database.insert('verse_collections', collection.toDatabase());
    return collection;
  }

  @override
  Future<List<VerseCollectionModel>> getVerseCollections() async {
    final result = await database.query('verse_collections', orderBy: 'createdAt DESC');
    return result.map((map) => VerseCollectionModel.fromDatabase(map)).toList();
  }

  @override
  Future<void> addVerseToCollection(String collectionId, String verseReference) async {
    // Get the collection
    final result = await database.query(
      'verse_collections',
      where: 'id = ?',
      whereArgs: [collectionId],
    );
    
    if (result.isNotEmpty) {
      final collection = VerseCollectionModel.fromDatabase(result.first);
      final updated = collection.verseReferences..add(verseReference);
      
      await database.update(
        'verse_collections',
        {'verseReferences': updated.join(',')},
        where: 'id = ?',
        whereArgs: [collectionId],
      );
    }
  }
}
