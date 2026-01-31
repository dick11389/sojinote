# 10-Day Flutter Streak Plan: Day 3

## 📅 Day 3: Repository & Use Cases

### 🎯 Learning Goals

- Understand the Repository pattern
- Learn how repositories abstract data sources
- Create repository interfaces in the domain layer
- Implement repositories in the data layer
- Build use cases for business operations
- Set up dependency injection

### 📝 What You'll Build

Today you'll build the bridge between data sources and business logic. Repositories act as the middleman, and use cases encapsulate single business operations.

---

### Step 1: Create Note Repository Interface

**File**: `lib/domain/repositories/note_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/note.dart';

abstract class NoteRepository {
  Future<Either<Failure, List<Note>>> getNotes();
  Future<Either<Failure, Note?>> getNoteById(String id);
  Future<Either<Failure, void>> addNote(Note note);
  Future<Either<Failure, void>> updateNote(Note note);
  Future<Either<Failure, void>> deleteNote(String id);
  Future<Either<Failure, List<Note>>> searchNotes(String query);
}
```

**🎓 What You're Learning:**

- **Repository Interface**: Defines contract, doesn't specify implementation
- **Either Type**: Every operation can fail, so we return Either<Failure, Result>
- **Domain Layer**: Only knows about Note entity, not NoteModel
- **Abstraction**: Data source implementation is hidden from domain

---

### Step 2: Implement Note Repository

**File**: `lib/data/repositories/note_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_local_datasource.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource localDataSource;

  NoteRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Note>>> getNotes() async {
    try {
      final notes = await localDataSource.getNotes();
      return Right(notes);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Note?>> getNoteById(String id) async {
    try {
      final note = await localDataSource.getNoteById(id);
      return Right(note);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addNote(Note note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      await localDataSource.addNote(noteModel);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateNote(Note note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      await localDataSource.updateNote(noteModel);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String id) async {
    try {
      await localDataSource.deleteNote(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Note>>> searchNotes(String query) async {
    try {
      final notes = await localDataSource.getNotes();
      final filtered = notes
          .where((note) =>
              note.title.toLowerCase().contains(query.toLowerCase()) ||
              note.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return Right(filtered);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}
```

**🎓 What You're Learning:**

- **Exception Translation**: Catches DatabaseException, converts to DatabaseFailure
- **Entity Conversion**: NoteModel converted back to Note for domain layer
- **Either Pattern**: Every method returns Either<Failure, Result>
- **Search Logic**: Simple client-side search (can move to database later)

---

### Step 3: Create Use Cases

**File**: `lib/domain/usecases/get_notes.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class GetNotes implements UseCase<List<Note>, NoParams> {
  final NoteRepository repository;

  GetNotes(this.repository);

  @override
  Future<Either<Failure, List<Note>>> call(NoParams params) async {
    return await repository.getNotes();
  }
}

class NoParams {}
```

**File**: `lib/domain/usecases/add_note.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class AddNote implements UseCase<void, AddNoteParams> {
  final NoteRepository repository;

  AddNote(this.repository);

  @override
  Future<Either<Failure, void>> call(AddNoteParams params) async {
    return await repository.addNote(params.note);
  }
}

class AddNoteParams {
  final Note note;
  AddNoteParams(this.note);
}
```

**File**: `lib/domain/usecases/update_note.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class UpdateNote implements UseCase<void, UpdateNoteParams> {
  final NoteRepository repository;

  UpdateNote(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateNoteParams params) async {
    return await repository.updateNote(params.note);
  }
}

class UpdateNoteParams {
  final Note note;
  UpdateNoteParams(this.note);
}
```

**File**: `lib/domain/usecases/delete_note.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/note_repository.dart';

class DeleteNote implements UseCase<void, DeleteNoteParams> {
  final NoteRepository repository;

  DeleteNote(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteNoteParams params) async {
    return await repository.deleteNote(params.id);
  }
}

class DeleteNoteParams {
  final String id;
  DeleteNoteParams(this.id);
}
```

**File**: `lib/domain/usecases/get_note_by_id.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class GetNoteById implements UseCase<Note?, GetNoteByIdParams> {
  final NoteRepository repository;

  GetNoteById(this.repository);

  @override
  Future<Either<Failure, Note?>> call(GetNoteByIdParams params) async {
    return await repository.getNoteById(params.id);
  }
}

class GetNoteByIdParams {
  final String id;
  GetNoteByIdParams(this.id);
}
```

**File**: `lib/domain/usecases/search_notes.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class SearchNotes implements UseCase<List<Note>, SearchNotesParams> {
  final NoteRepository repository;

  SearchNotes(this.repository);

  @override
  Future<Either<Failure, List<Note>>> call(SearchNotesParams params) async {
    return await repository.searchNotes(params.query);
  }
}

class SearchNotesParams {
  final String query;
  SearchNotesParams(this.query);
}
```

**🎓 What You're Learning:**

- **Single Responsibility**: Each use case = one operation
- **Parameters Object**: Each use case has its own params class
- **Call Method**: BLoC will call use cases like functions: `getNotesUseCase(NoParams())`

---

### Step 4: Update Dependency Injection

**File**: `lib/core/di/injection_container.dart`

```dart
import 'package:get_it/get_it.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/datasources/note_local_datasource.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_note_by_id.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/search_notes.dart';
import '../../domain/usecases/update_note.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Data sources
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  getIt.registerLazySingleton<NoteLocalDataSource>(
    () => NoteLocalDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(localDataSource: getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetNotes(getIt()));
  getIt.registerLazySingleton(() => GetNoteById(getIt()));
  getIt.registerLazySingleton(() => AddNote(getIt()));
  getIt.registerLazySingleton(() => UpdateNote(getIt()));
  getIt.registerLazySingleton(() => DeleteNote(getIt()));
  getIt.registerLazySingleton(() => SearchNotes(getIt()));
}
```

**🎓 What You're Learning:**

- **Dependency Graph**: Each layer depends on layer below it
- **Lazy Singletons**: Services created when first needed, then reused
- **Automatic Injection**: `getIt()` in constructor automatically provides registered type

---

### 📦 Commit Your Work

```bash
git add .
git commit -m "Day 3: Implement repository pattern and use cases

- Created NoteRepository interface in domain layer
- Implemented NoteRepositoryImpl with error transformation
- Created 6 use cases: GetNotes, GetNoteById, AddNote, UpdateNote, DeleteNote, SearchNotes
- Set up dependency injection with GetIt
- Connected all layers (data → domain)

Learning: Repository pattern provides abstraction. Use cases encapsulate single business operations."

git push origin main
```

---

### 📖 Blog Entry: Day 3

**Title**: "Bridging Layers: Repositories and Use Cases"

**What I Built Today:**
Today was about connecting the dots! I implemented:

- Repository interfaces in the domain layer
- Repository implementations that use data sources
- 6 use cases for all note operations
- Dependency injection configuration

The key insight: **Repository pattern is the bridge between messy data sources and clean domain logic.**

**What I Learned:**

1. **Why Repositories Matter**:
   Without repositories, my domain layer would depend on database implementation. With them:

   ```dart
   // Domain layer only knows about interface
   abstract class NoteRepository {
     Future<Either<Failure, List<Note>>> getNotes();
   }

   // Implementation is hidden in data layer
   class NoteRepositoryImpl implements NoteRepository {
     // Could use SQLite, Firestore, REST API...
   }
   ```

   This means I can swap implementations without touching domain code!

2. **Either Pattern for Error Handling**:

   ```dart
   try {
     final notes = await localDataSource.getNotes();
     return Right(notes);  // Success
   } on DatabaseException catch (e) {
     return Left(DatabaseFailure(e.message));  // Failure
   }
   ```

   This forces explicit error handling everywhere. No forgotten catch blocks!

3. **Use Case Pattern**:
   Each use case is simple but focused:

   ```dart
   class GetNotes implements UseCase<List<Note>, NoParams> {
     @override
     Future<Either<Failure, List<Note>>> call(NoParams params) async {
       return await repository.getNotes();
     }
   }
   ```

   This might seem like overkill, but it makes testing incredibly easy.

4. **Parameter Objects**:
   Instead of multiple parameters, each use case gets a params object:

   ```dart
   // Instead of: repository.deleteNote(noteId, userId, timestamp)
   // We use: deleteNoteUseCase(DeleteNoteParams(noteId))
   ```

   This makes it easy to add parameters later without refactoring.

5. **Dependency Injection Graph**:
   ```
   DatabaseHelper (lowest level)
           ↓
   NoteLocalDataSource
           ↓
   NoteRepository
           ↓
   Use Cases (GetNotes, AddNote, etc.)
           ↓
   BLoC (tomorrow!)
   ```
   Each layer depends on the one below, never the other way around.

**Challenges:**

1. **Understanding Either Type**: Took a moment to remember that `Left` = failure, `Right` = success. It's intuitive once you think about it (Right = Correct).

2. **Multiple Parameter Classes**: Feels verbose creating a params class for each use case, but it pays off in flexibility and testability.

**Code Highlights:**

The repository implementation is beautifully simple:

```dart
@override
Future<Either<Failure, List<Note>>> getNotes() async {
  try {
    final notes = await localDataSource.getNotes();
    return Right(notes);
  } on DatabaseException catch (e) {
    return Left(DatabaseFailure(e.message));
  }
}
```

It's just:

1. Call the data source
2. Return success if no exception
3. Catch database exception, return failure

**Tomorrow's Plan:**
Day 4 I'll create the BLoC that uses these use cases!

**Stats Today:**

- 📁 Files created: 8 (1 interface, 1 implementation, 6 use cases)
- 📝 Lines of code: ~300
- ⏱️ Time spent: ~50 minutes
- 🚀 Progress: Business logic layer complete!

**Key Insight:**
I finally understand why senior developers emphasize architecture. The code I wrote today can be tested without a database, without Flutter, without anything except the use case logic. That's powerful!

---

## 🎯 Key Takeaways

✅ **Repository pattern decouples data sources from business logic**
✅ **Use cases are single-responsibility containers for operations**
✅ **Either type forces explicit error handling**
✅ **Dependency injection makes testing possible**

**Next**: Day 4 - BLoC State Management
