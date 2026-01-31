import 'package:sqflite/sqflite.dart';
import '../models/note_model.dart';

abstract class NoteLocalDataSource {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel> getNoteById(String id);
  Future<void> insertNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
}

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  final Database database;

  NoteLocalDataSourceImpl({required this.database});

  @override
  Future<List<NoteModel>> getNotes() async {
    final List<Map<String, dynamic>> maps = await database.query('notes');
    return List.generate(maps.length, (i) => NoteModel.fromJson(maps[i]));
  }

  @override
  Future<NoteModel> getNoteById(String id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    return NoteModel.fromJson(maps.first);
  }

  @override
  Future<void> insertNote(NoteModel note) async {
    await database.insert('notes', note.toJson());
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    await database.update(
      'notes',
      note.toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  @override
  Future<void> deleteNote(String id) async {
    await database.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
