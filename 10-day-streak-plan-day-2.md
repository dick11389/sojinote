# 10-Day Flutter Streak Plan: Day 2

## 📅 Day 2: Database Setup & Note Entity

### 🎯 Learning Goals

- Understand the Entity vs Model distinction
- Set up SQLite database with sqflite
- Implement complete CRUD operations
- Learn about database indexing for performance
- Handle async database operations

### 📝 What You'll Build

Today you'll create the database foundation for storing sermon notes. You'll learn how entities represent business objects and models handle data serialization.

---

### Step 1: Create Note Entity

**File**: `lib/domain/entities/note.dart`

```dart
import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy of this note with some fields replaced
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, content, createdAt, updatedAt];
}
```

**🎓 What You're Learning:**

- **Entity**: Pure business object, no framework dependencies
- **Equatable**: Compares objects by value, not reference
- **copyWith**: Creates modified copies (immutability pattern)
- **Props**: Defines what makes two notes equal

---

### Step 2: Create Note Model

**File**: `lib/data/models/note_model.dart`

```dart
import 'package:sermon_notes/domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Convert entity to model
  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  /// Convert JSON to model (from database)
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] as int,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        json['updatedAt'] as int,
      ),
    );
  }

  /// Convert model to JSON (for database)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}
```

**🎓 What You're Learning:**

- **Model extends Entity**: Adds serialization without changing business logic
- **fromJson/toJson**: Converts between Dart objects and database format
- **DateTime Serialization**: Must convert to milliseconds for database
- **Factory Constructors**: Different ways to create instances

---

### Step 3: Create Database Helper

**File**: `lib/data/datasources/database_helper.dart`

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/api_constants.dart';

class DatabaseHelper {
  static const String _tableName = 'notes';
  static const String _columnId = 'id';
  static const String _columnTitle = 'title';
  static const String _columnContent = 'content';
  static const String _columnCreatedAt = 'createdAt';
  static const String _columnUpdatedAt = 'updatedAt';

  static Database? _database;

  /// Get database instance (singleton pattern)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, ApiConstants.databaseName);

    return await openDatabase(
      path,
      version: ApiConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Create tables on first run
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $_columnId TEXT PRIMARY KEY,
        $_columnTitle TEXT NOT NULL,
        $_columnContent TEXT NOT NULL,
        $_columnCreatedAt INTEGER NOT NULL,
        $_columnUpdatedAt INTEGER NOT NULL
      )
    ''');

    // Create index for faster queries on updatedAt
    await db.execute('''
      CREATE INDEX idx_updated_at ON $_tableName($_columnUpdatedAt DESC)
    ''');
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
```

**🎓 What You're Learning:**

- **Singleton Pattern**: Database initialized once, reused
- **Migrations**: onCreate runs only on first app install
- **Indexes**: Make queries faster (especially for sorting)
- **Async/Await**: Database operations are asynchronous

---

### Step 4: Create Local Data Source

**File**: `lib/data/datasources/note_local_datasource.dart`

```dart
import 'package:sqflite/sqflite.dart';
import '../../core/error/exceptions.dart';
import '../models/note_model.dart';
import 'database_helper.dart';

abstract class NoteLocalDataSource {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel?> getNoteById(String id);
  Future<void> addNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
  Future<void> clearAllNotes();
}

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  final DatabaseHelper databaseHelper;

  NoteLocalDataSourceImpl(this.databaseHelper);

  static const _tableName = 'notes';

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final db = await databaseHelper.database;
      final result = await db.query(
        _tableName,
        orderBy: 'updatedAt DESC',
      );
      return result.map((json) => NoteModel.fromJson(json)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch notes: $e');
    }
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    try {
      final db = await databaseHelper.database;
      final result = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return NoteModel.fromJson(result.first);
    } catch (e) {
      throw DatabaseException('Failed to fetch note: $e');
    }
  }

  @override
  Future<void> addNote(NoteModel note) async {
    try {
      final db = await databaseHelper.database;
      await db.insert(_tableName, note.toJson());
    } catch (e) {
      throw DatabaseException('Failed to add note: $e');
    }
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        _tableName,
        note.toJson(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
    } catch (e) {
      throw DatabaseException('Failed to update note: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete note: $e');
    }
  }

  @override
  Future<void> clearAllNotes() async {
    try {
      final db = await databaseHelper.database;
      await db.delete(_tableName);
    } catch (e) {
      throw DatabaseException('Failed to clear notes: $e');
    }
  }
}
```

**🎓 What You're Learning:**

- **Interface Segregation**: Interface defines contract, implementation hidden
- **CRUD Operations**: Create, Read, Update, Delete pattern
- **Error Translation**: Database exceptions thrown here
- **Query Ordering**: Results ordered by updatedAt DESC (newest first)
- **Where Clauses**: Filter queries by ID

---

### Step 5: Update pubspec.yaml

Add the missing dependency:

```yaml
dependencies:
  dartz: ^0.10.1 # For Either type
```

Then run `flutter pub get`.

---

### 📦 Commit Your Work

```bash
git add .
git commit -m "Day 2: Implement SQLite database and Note entity

- Created Note entity with copyWith and Equatable
- Implemented NoteModel with JSON serialization
- Set up DatabaseHelper for SQLite initialization
- Created NoteLocalDataSource for CRUD operations
- Added indexes for query optimization
- Implemented comprehensive error handling

Learning: Understood the difference between entities (business objects) and models (data transfer objects)."

git push origin main
```

---

### 📖 Blog Entry: Day 2

**Title**: "Database Foundations: SQLite, Entities, and Models"

**What I Built Today:**
After yesterday's architecture foundation, today I brought data to life! I implemented:

- A `Note` entity representing sermon notes
- A `NoteModel` for database serialization
- Complete SQLite database setup with CRUD operations
- Comprehensive error handling

**What I Learned:**

1. **Entity vs Model Pattern**:
   The distinction between these two was a revelation:

   ```dart
   // Entity: Pure business object
   class Note extends Equatable {
     final String id, title, content;
   }

   // Model: Adds serialization
   class NoteModel extends Note {
     factory NoteModel.fromJson(Map<String, dynamic> json) { ... }
     Map<String, dynamic> toJson() { ... }
   }
   ```

   This keeps business logic separate from data format concerns.

2. **DateTime Serialization**:
   SQLite doesn't have a DateTime type, so I convert to milliseconds:

   ```dart
   createdAt.millisecondsSinceEpoch  // Store as int
   DateTime.fromMillisecondsSinceEpoch(value)  // Retrieve
   ```

3. **Database Indexing**:
   Adding `CREATE INDEX idx_updated_at` on the updatedAt column dramatically speeds up sorted queries. This is crucial for "show newest notes first".

4. **Singleton Pattern for Database**:

   ```dart
   static Database? _database;

   Future<Database> get database async {
     if (_database != null) return _database!;
     _database = await _initDatabase();
     return _database!;
   }
   ```

   This ensures only one database connection throughout the app's lifetime.

5. **CRUD Operations**:
   Implemented all four operations with proper error handling:
   - **Create**: `addNote(NoteModel note)`
   - **Read**: `getNotes()`, `getNoteById(id)`
   - **Update**: `updateNote(NoteModel note)`
   - **Delete**: `deleteNote(id)`

**Challenges:**

1. **DateTime Precision**: Initially forgot that DateTime has microseconds but SQLite uses milliseconds.

2. **Async/Await Confusion**: Had to remember that database operations are async, so they return `Future<T>`, not `T`.

3. **Interface vs Implementation**: Took a moment to understand why I need both `NoteLocalDataSource` (interface) and `NoteLocalDataSourceImpl` (implementation).

**Why This Matters:**
The code I wrote today will persist data even after the app closes. Without this layer, all sermon notes would be lost! The interface-based design also means tomorrow I can swap in a different data source (Cloud Firestore, for example) without changing any other code.

**Stats Today:**

- 📁 Files created: 3
- 📝 Lines of code: ~200
- ⏱️ Time spent: ~45 minutes
- 🚀 Progress: Data layer complete!

**Code Highlights:**

The `copyWith` method deserves special mention:

```dart
Note copyWith({
  String? id,
  String? title,
  String? content,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return Note(
    id: id ?? this.id,
    title: title ?? this.title,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
```

This creates a new Note with updated fields, maintaining immutability. The `??` operator (null coalescing) keeps existing values if new ones aren't provided.

**Tomorrow's Plan:**
Day 3 brings it all together! I'll:

- Create repository interfaces in domain layer
- Implement repositories that use the data source
- Create use cases for GetNotes, AddNote, UpdateNote, DeleteNote
- Connect everything with dependency injection

**Key Insight:**
Today reinforced that Flutter apps aren't just UI. Data persistence, error handling, and clean architecture are equally important. The 10 minutes I spent on database indexing will save countless milliseconds over the app's lifetime.

---

## 🎯 Key Takeaways

✅ **Entity-Model separation is powerful**
✅ **Proper indexing prevents future performance issues**
✅ **CRUD operations are foundational**
✅ **Interfaces enable testing and flexibility**

**Next**: Day 3 - Repository Pattern & Use Cases
