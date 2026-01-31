import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../data/datasources/note_local_datasource.dart';
import '../../data/datasources/bible_remote_datasource.dart';
import '../../data/datasources/bible_api_service.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../data/repositories/bible_repository_impl.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/repositories/bible_repository.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/detect_bible_verses.dart';
import '../../domain/usecases/get_verse.dart';
import '../../presentation/bloc/notes/notes_bloc.dart';
import '../../presentation/bloc/bible_toolkit/bible_toolkit_bloc.dart';
import '../../presentation/bloc/verse_fetch/verse_fetch_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoC
  sl.registerFactory(() => NotesBloc(
    getNotes: sl(),
    addNote: sl(),
  ));
  
  sl.registerFactory(() => BibleToolkitBloc(
    detectBibleVerses: sl(),
    getVerse: sl(),
  ));

  sl.registerFactory(() => VerseFetchBloc(
    getVerse: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => GetNotes(sl()));
  sl.registerLazySingleton(() => AddNote(sl()));
  sl.registerLazySingleton(() => DetectBibleVerses(sl()));
  sl.registerLazySingleton(() => GetVerse(sl()));

  // Repository
  sl.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(localDataSource: sl()),
  );
  
  sl.registerLazySingleton<BibleRepository>(
    () => BibleRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<NoteLocalDataSource>(
    () => NoteLocalDataSourceImpl(database: sl()),
  );
  
  sl.registerLazySingleton<BibleRemoteDataSource>(
    () => BibleRemoteDataSourceImpl(apiService: sl()),
  );

  // API Services
  sl.registerLazySingleton<BibleApiService>(
    () => BibleApiServiceImpl(client: sl()),
  );

  // External
  final database = await _initDatabase();
  sl.registerLazySingleton(() => database);
  sl.registerLazySingleton(() => http.Client());
}

Future<Database> _initDatabase() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'sermon_notes.db');

  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          createdAt INTEGER NOT NULL,
          updatedAt INTEGER NOT NULL
        )
      ''');
    },
  );
}
