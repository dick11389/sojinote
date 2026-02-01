import 'package:sqflite/sqflite.dart';
import '../../domain/entities/bible_translation.dart';
import '../models/bible_translation_model.dart';

abstract class TranslationDatasource {
  Future<List<BibleTranslationModel>> getAvailableTranslations();
  Future<BibleTranslationModel?> getDefaultTranslation();
  Future<void> setDefaultTranslation(String translationCode);
  Future<void> saveTranslation(BibleTranslationModel translation);
  Future<void> deleteTranslation(String translationCode);
  Future<BibleTranslationModel?> getTranslationByCode(String code);
}

class TranslationDatasourceImpl implements TranslationDatasource {
  final Database database;

  TranslationDatasourceImpl({required this.database});

  @override
  Future<List<BibleTranslationModel>> getAvailableTranslations() async {
    final result = await database.query('bible_translations');
    return result.map((map) => BibleTranslationModel.fromDatabase(map)).toList();
  }

  @override
  Future<BibleTranslationModel?> getDefaultTranslation() async {
    final result = await database.query(
      'bible_translations',
      where: 'isDefault = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return BibleTranslationModel.fromDatabase(result.first);
    }
    return null;
  }

  @override
  Future<void> setDefaultTranslation(String translationCode) async {
    // Remove default from all translations
    await database.execute('UPDATE bible_translations SET isDefault = 0');
    // Set new default
    await database.update(
      'bible_translations',
      {'isDefault': 1},
      where: 'code = ?',
      whereArgs: [translationCode],
    );
  }

  @override
  Future<void> saveTranslation(BibleTranslationModel translation) async {
    await database.insert(
      'bible_translations',
      translation.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteTranslation(String translationCode) async {
    await database.delete(
      'bible_translations',
      where: 'code = ? AND isDefault = ?',
      whereArgs: [translationCode, 0],
    );
  }

  @override
  Future<BibleTranslationModel?> getTranslationByCode(String code) async {
    final result = await database.query(
      'bible_translations',
      where: 'code = ?',
      whereArgs: [code],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return BibleTranslationModel.fromDatabase(result.first);
    }
    return null;
  }
}
