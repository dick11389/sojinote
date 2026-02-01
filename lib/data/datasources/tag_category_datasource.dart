import 'package:sqflite/sqflite.dart';
import '../../domain/entities/note_tag.dart';
import '../models/note_tag_model.dart';

abstract class TagCategoryLocalDatasource {
  Future<NoteTagModel> createTag(String name, String color, String? description);
  Future<List<NoteTagModel>> getAllTags();
  Future<void> deleteTag(String tagId);
  Future<void> addTagToNote(String noteId, String tagId);
  Future<List<String>> getNotesByTag(String tagId);
  
  Future<NoteCategoryModel> createCategory(String name, String icon, String? description);
  Future<List<NoteCategoryModel>> getAllCategories();
  Future<void> setCategoryForNote(String noteId, String categoryId);
}

class TagCategoryLocalDatasourceImpl implements TagCategoryLocalDatasource {
  final Database database;

  TagCategoryLocalDatasourceImpl({required this.database});

  @override
  Future<NoteTagModel> createTag(String name, String color, String? description) async {
    final tagId = 'tag_${DateTime.now().millisecondsSinceEpoch}';
    final tag = NoteTagModel(
      id: tagId,
      name: name,
      color: color,
      description: description,
      createdAt: DateTime.now(),
      usageCount: 0,
    );
    await database.insert('note_tags', tag.toDatabase());
    return tag;
  }

  @override
  Future<List<NoteTagModel>> getAllTags() async {
    final result = await database.query('note_tags', orderBy: 'usageCount DESC');
    return result.map((map) => NoteTagModel.fromDatabase(map)).toList();
  }

  @override
  Future<void> deleteTag(String tagId) async {
    await database.delete('note_tags', where: 'id = ?', whereArgs: [tagId]);
  }

  @override
  Future<void> addTagToNote(String noteId, String tagId) async {
    try {
      await database.insert(
        'note_tags_junction',
        {'noteId': noteId, 'tagId': tagId},
      );
      // Increment usage count
      await database.execute(
        'UPDATE note_tags SET usageCount = usageCount + 1 WHERE id = ?',
        [tagId],
      );
    } catch (e) {
      throw Exception('Failed to add tag to note: $e');
    }
  }

  @override
  Future<List<String>> getNotesByTag(String tagId) async {
    final result = await database.query(
      'note_tags_junction',
      where: 'tagId = ?',
      whereArgs: [tagId],
    );
    return result.map((row) => row['noteId'] as String).toList();
  }

  @override
  Future<NoteCategoryModel> createCategory(String name, String icon, String? description) async {
    final categoryId = 'cat_${DateTime.now().millisecondsSinceEpoch}';
    final category = NoteCategoryModel(
      id: categoryId,
      name: name,
      icon: icon,
      description: description,
      createdAt: DateTime.now(),
      noteCount: 0,
    );
    await database.insert('note_categories', category.toDatabase());
    return category;
  }

  @override
  Future<List<NoteCategoryModel>> getAllCategories() async {
    final result = await database.query('note_categories', orderBy: 'noteCount DESC');
    return result.map((map) => NoteCategoryModel.fromDatabase(map)).toList();
  }

  @override
  Future<void> setCategoryForNote(String noteId, String categoryId) async {
    try {
      await database.update(
        'notes',
        {'categoryId': categoryId},
        where: 'id = ?',
        whereArgs: [noteId],
      );
      // Increment note count
      await database.execute(
        'UPDATE note_categories SET noteCount = noteCount + 1 WHERE id = ?',
        [categoryId],
      );
    } catch (e) {
      throw Exception('Failed to set category for note: $e');
    }
  }
}
