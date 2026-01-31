# SermonNotes App - Complete File Structure Guide

## 📁 Project Root Directory

```
sermon_notes/
├── lib/                          # Main application code
├── test/                         # Unit and widget tests
├── android/                      # Android-specific configuration
├── ios/                          # iOS-specific configuration
├── web/                          # Web-specific configuration
├── pubspec.yaml                  # Project dependencies and metadata
├── pubspec.lock                  # Locked dependency versions
├── analysis_options.yaml         # Dart analyzer configuration
├── README.md                     # Project documentation
├── explanation.md                # Technical explanation document
└── file_structure.md            # This file
```

---

## 📂 Root Directory Files

### `pubspec.yaml`

**Purpose**: Project configuration and dependency management

```yaml
# Defines:
- Project name and description
- Flutter SDK version requirements
- Dependencies (packages used in production)
- Dev dependencies (packages used for development/testing)
- Assets (images, fonts, etc.)
```

**Key Dependencies in This Project:**

- `flutter_bloc` - State management
- `sqflite` - Local SQLite database
- `http` - API calls
- `rxdart` - Reactive streams and debouncing
- `get_it` - Dependency injection
- `uuid` - Unique ID generation
- `equatable` - Value object comparison

### `pubspec.lock`

**Purpose**: Auto-generated file that locks exact versions of all dependencies and their transitive dependencies. Ensures consistent builds across different machines.

### `analysis_options.yaml`

**Purpose**: Configures Dart static analysis rules

```yaml
# Defines:
- Linting rules (code style enforcement)
- Error severity levels
- Code quality standards
```

### `README.md`

**Purpose**: Project documentation for developers

- Setup instructions
- How to run the app
- Project overview
- Contributing guidelines

### `explanation.md`

**Purpose**: Technical architecture and feature explanation

- How the app works
- Architecture decisions
- Data flow examples
- Design patterns used

---

## 📂 The `lib/` Directory - Main Application Code

The `lib/` directory contains all the Dart code for the application, organized following Clean Architecture principles.

```
lib/
├── core/                   # Shared utilities and infrastructure
├── data/                   # Data layer (repositories, data sources)
├── domain/                 # Business logic layer
├── presentation/           # UI layer (screens, widgets, BLoCs)
└── main.dart              # Application entry point
```

---

## 🎯 `lib/main.dart` - Application Entry Point

**Purpose**: The starting point of the Flutter application

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  // Run the app
  runApp(const MyApp());
}
```

**Key Responsibilities:**

1. Initialize Flutter engine
2. Set up dependency injection (GetIt)
3. Initialize database
4. Run the root widget (`MyApp`)

**Flow:**

```
main() → Initialize DI → Setup DB → Create MyApp Widget → Show UI
```

---

## 🏗️ `lib/core/` - Core Infrastructure

Shared code used across all layers. This is the foundation that supports the entire application.

```
core/
├── constants/              # Application-wide constants
├── di/                     # Dependency Injection setup
├── error/                  # Error handling infrastructure
└── usecases/              # Base use case interface
```

### 📁 `core/constants/`

#### `api_constants.dart`

**Purpose**: Centralized API configuration

```dart
class ApiConstants {
  // API URLs
  static const String bibleApiBaseUrl = 'https://bible-api.com';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);

  // Error messages
  static const String noInternetError = 'No internet connection...';
  static const String verseNotFoundError = 'Bible verse not found...';
  // ... more error messages
}
```

**Why It Exists:**

- Single source of truth for API configuration
- Easy to update URLs without searching entire codebase
- Consistent error messages throughout the app
- Easy to switch between development/production environments

---

### 📁 `core/di/`

#### `injection_container.dart`

**Purpose**: Dependency Injection configuration using GetIt

```dart
final sl = GetIt.instance;  // Service Locator

Future<void> init() async {
  // Register BLoCs (factories - new instance each time)
  sl.registerFactory(() => NotesBloc(...));

  // Register Use Cases (singletons - one instance shared)
  sl.registerLazySingleton(() => GetNotes(sl()));

  // Register Repositories
  sl.registerLazySingleton<NoteRepository>(() => NoteRepositoryImpl(...));

  // Register Data Sources
  sl.registerLazySingleton<NoteLocalDataSource>(() => NoteLocalDataSourceImpl(...));

  // Register External Dependencies
  final database = await DatabaseHelper.initDatabase();
  sl.registerLazySingleton(() => database);
  sl.registerLazySingleton(() => http.Client());
}
```

**Dependency Graph:**

```
BLoC
  ↓ depends on
Use Case
  ↓ depends on
Repository
  ↓ depends on
Data Source
  ↓ depends on
External (Database/HTTP)
```

**Benefits:**

- Decoupled components (easy to swap implementations)
- Easy to mock for testing
- Automatic dependency resolution
- Lazy loading (only created when needed)

**Registration Types:**

- `registerFactory`: New instance every time (used for BLoCs)
- `registerLazySingleton`: Single instance created on first use
- `registerSingleton`: Single instance created immediately

---

### 📁 `core/error/`

#### `exceptions.dart`

**Purpose**: Custom exception classes for the data layer

```dart
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}
```

**Why Separate Exception Types:**

- Different handling strategies for different errors
- Clear error origin (network vs database vs server)
- Better error messages to users
- Easier debugging

**When Each Is Thrown:**

- `NetworkException`: No internet, timeout
- `NotFoundException`: 404, verse not found
- `ServerException`: 500+, API errors
- `CacheException`: Database errors, disk full

#### `failures.dart`

**Purpose**: Domain layer failures (converted from exceptions)

```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(String message) : super(message);
}
```

**Error Flow:**

```
Data Layer throws Exception
  ↓
Repository catches Exception
  ↓
Repository throws Failure
  ↓
BLoC catches Failure
  ↓
UI shows user-friendly message
```

---

### 📁 `core/usecases/`

#### `usecase.dart`

**Purpose**: Base interface for all use cases

```dart
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

// For use cases with no parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
```

**Why This Pattern:**

- Consistent interface for all business logic
- Single Responsibility Principle (one use case = one action)
- Easy to test in isolation
- Clear separation of concerns

**Example Usage:**

```dart
class GetNotes implements UseCase<List<Note>, NoParams> {
  final NoteRepository repository;

  GetNotes(this.repository);

  @override
  Future<List<Note>> call(NoParams params) async {
    return await repository.getNotes();
  }
}

// Usage in BLoC:
final notes = await getNotes(NoParams());
```

---

## 💾 `lib/data/` - Data Layer

Handles all data operations: API calls, database queries, caching. This layer knows HOW to get data but not WHAT to do with it.

```
data/
├── datasources/            # Raw data access (API, Database)
├── models/                 # Data models (JSON serialization)
└── repositories/           # Repository implementations
```

### 📁 `data/datasources/`

Data sources are the lowest level - they directly interact with external systems.

#### `database_helper.dart`

**Purpose**: SQLite database initialization and schema management

```dart
class DatabaseHelper {
  static const String _databaseName = 'sermon_notes.db';
  static const int _databaseVersion = 1;

  static Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create tables
    await db.execute('''CREATE TABLE notes(...)''');

    // Create indexes for performance
    await db.execute('''CREATE INDEX idx_notes_created_at...''');
  }
}
```

**Responsibilities:**

- Database creation
- Schema definition
- Table creation
- Index creation for performance
- Database upgrades (version management)

**Why Separate Helper:**

- Reusable across multiple data sources
- Centralized schema management
- Easy to add new tables
- Version migration logic in one place

#### `note_local_datasource.dart`

**Purpose**: Local database operations for notes

```dart
abstract class NoteLocalDataSource {
  Future<List<NoteModel>> getNotes({String? orderBy, bool ascending});
  Future<NoteModel> getNoteById(String id);
  Future<void> insertNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
  Future<int> getNotesCount();
  Future<List<NoteModel>> searchNotes(String query);
}

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  final Database database;

  // Implementation using SQLite queries
  @override
  Future<List<NoteModel>> getNotes(...) async {
    final maps = await database.query('notes', orderBy: '...');
    return List.generate(maps.length, (i) => NoteModel.fromJson(maps[i]));
  }

  // ... more implementations
}
```

**Interface + Implementation Pattern:**

- `NoteLocalDataSource` = Abstract interface (contract)
- `NoteLocalDataSourceImpl` = Concrete implementation

**Benefits:**

- Easy to mock for testing
- Can swap implementations (e.g., switch from SQLite to Hive)
- Repository depends on interface, not implementation

**SQL Operations:**

```dart
// Query
database.query('notes', where: 'id = ?', whereArgs: [id])

// Insert
database.insert('notes', note.toJson())

// Update
database.update('notes', note.toJson(), where: 'id = ?', whereArgs: [id])

// Delete
database.delete('notes', where: 'id = ?', whereArgs: [id])

// Search
database.query('notes', where: 'title LIKE ? OR content LIKE ?', whereArgs: ['%query%', '%query%'])
```

#### `bible_api_service.dart`

**Purpose**: HTTP API calls to bible-api.com

```dart
abstract class BibleApiService {
  Future<BibleVerseModel> fetchVerseText(String reference);
  Future<List<BibleVerseModel>> fetchMultipleVerses(List<String> references);
}

class BibleApiServiceImpl implements BibleApiService {
  final http.Client client;

  @override
  Future<BibleVerseModel> fetchVerseText(String reference) async {
    final url = Uri.parse('$baseUrl/$encodedReference');
    final response = await client.get(url).timeout(Duration(seconds: 30));

    return _handleResponse(response);
  }

  BibleVerseModel _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200: return BibleVerseModel.fromJson(json.decode(response.body));
      case 404: throw NotFoundException('Verse not found');
      case 500: throw ServerException('Server error');
      // ... more cases
    }
  }
}
```

**Error Handling Strategy:**

```
SocketException → NetworkException (no internet)
TimeoutException → NetworkException (connection timeout)
404 status → NotFoundException (verse not found)
500+ status → ServerException (server error)
FormatException → ServerException (invalid JSON)
```

**Why Separate from Repository:**

- Single responsibility (only handles HTTP)
- Reusable for different repositories
- Easy to mock HTTP calls in tests
- Can add caching layer independently

#### `bible_remote_datasource.dart`

**Purpose**: Wrapper around BibleApiService with additional business logic

```dart
abstract class BibleRemoteDataSource {
  Future<BibleVerseModel> fetchVerse(String reference);
  Future<List<BibleVerseModel>> fetchMultipleVerses(List<String> references);
}

class BibleRemoteDataSourceImpl implements BibleRemoteDataSource {
  final BibleApiService apiService;

  @override
  Future<BibleVerseModel> fetchVerse(String reference) async {
    try {
      return await apiService.fetchVerseText(reference);
    } catch (e) {
      // Transform exceptions, add logging, caching, etc.
      if (e is NetworkException) throw NetworkException(e.message);
      // ...
    }
  }
}
```

**Why This Layer:**

- Can add caching without changing API service
- Can add retry logic
- Can add logging
- Separates API contract from data source contract

---

### 📁 `data/models/`

Models are data transfer objects that handle serialization/deserialization.

#### `note_model.dart`

**Purpose**: Serializable version of Note entity

```dart
class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
  });

  // From JSON (database/API)
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
    );
  }

  // To JSON (database/API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // From Entity
  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }
}
```

**Why Extend Entity:**

- Model IS-A Entity (can be used anywhere Entity is expected)
- Adds serialization capabilities
- No need for manual conversion in most cases

**Model vs Entity:**

- **Entity**: Pure business object (no serialization logic)
- **Model**: Data transfer object (knows about JSON, database format)

**Benefits:**

- Entity can change without affecting database schema
- Can have multiple models for same entity (e.g., API model, DB model)
- Testable serialization logic

#### `bible_verse_model.dart`

**Purpose**: Serializable version of BibleVerse entity

```dart
class BibleVerseModel extends BibleVerse {
  const BibleVerseModel({...});

  factory BibleVerseModel.fromJson(Map<String, dynamic> json) {
    final reference = json['reference'] as String;
    final parts = _parseReference(reference);  // "John 3:16" → {book: "John", chapter: 3, verse: 16}

    return BibleVerseModel(
      reference: reference,
      text: _cleanText(json['text']),
      book: parts['book'],
      chapter: parts['chapter'],
      verse: parts['verse'],
    );
  }

  static Map<String, dynamic> _parseReference(String reference) {
    // Regex to extract book, chapter, verse from "John 3:16"
    final pattern = RegExp(r'^((?:\d\s+)?[A-Za-z\s]+)\s+(\d+):(\d+)');
    final match = pattern.firstMatch(reference);
    // ...
  }

  static String _cleanText(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
```

**Special Features:**

- Parses API response format
- Extracts structured data from reference string
- Cleans text formatting

---

### 📁 `data/repositories/`

Repositories implement domain interfaces and coordinate data sources.

#### `note_repository_impl.dart`

**Purpose**: Implementation of NoteRepository interface

```dart
class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource localDataSource;

  NoteRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Note>> getNotes({String? orderBy, bool ascending = false}) async {
    try {
      return await localDataSource.getNotes(orderBy: orderBy, ascending: ascending);
    } on CacheException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  @override
  Future<void> addNote(Note note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      await localDataSource.insertNote(noteModel);
    } on CacheException catch (e) {
      throw DatabaseFailure(e.message);
    }
  }

  // ... more implementations
}
```

**Responsibilities:**

- Implement domain repository interface
- Coordinate data sources (local, remote, cache)
- Transform exceptions to failures
- Convert entities to models and vice versa

**Error Transformation:**

```
CacheException (data layer)
  ↓ caught and transformed
DatabaseFailure (domain layer)
  ↓ handled by
BLoC (presentation layer)
  ↓ shown as
User-friendly message (UI)
```

**Why Repository Pattern:**

- Domain layer doesn't know about data sources
- Easy to add caching (check cache, then API)
- Can switch data sources without changing domain
- Testable with mocked data sources

#### `bible_repository_impl.dart`

**Purpose**: Implementation of BibleRepository interface

```dart
class BibleRepositoryImpl implements BibleRepository {
  final BibleRemoteDataSource remoteDataSource;

  @override
  Future<BibleVerse> getVerse(String reference) async {
    try {
      return await remoteDataSource.fetchVerse(reference);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on NotFoundException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
  Future<List<BibleVerse>> getMultipleVerses(List<String> references) async {
    try {
      return await remoteDataSource.fetchMultipleVerses(references);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }
}
```

**Could Be Enhanced With:**

```dart
// Caching example
@override
Future<BibleVerse> getVerse(String reference) async {
  // Check cache first
  final cached = await cacheDataSource.getVerse(reference);
  if (cached != null) return cached;

  // Fetch from API
  final verse = await remoteDataSource.fetchVerse(reference);

  // Save to cache
  await cacheDataSource.saveVerse(verse);

  return verse;
}
```

---

## 🎯 `lib/domain/` - Domain Layer

The heart of the application. Contains business logic, entities, and contracts. This layer is completely independent of frameworks and external dependencies.

```
domain/
├── entities/               # Business objects (pure Dart classes)
├── repositories/           # Repository interfaces (contracts)
├── usecases/              # Business logic use cases
└── utils/                 # Domain utilities
```

### 📁 `domain/entities/`

Entities are pure business objects with no dependencies on external packages.

#### `note.dart`

**Purpose**: Core business object representing a sermon note

```dart
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
  List<Object> get props => [id, title, content, createdAt, updatedAt];
}
```

**Why Extend Equatable:**

- Value-based comparison (not reference-based)
- Two notes with same data are considered equal
- Makes testing easier
- Required for BLoC state comparison

**copyWith Method:**

- Immutability pattern
- Create new instance with modified fields
- Prevents accidental mutations

**Properties:**

- `id`: Unique identifier (UUID v4)
- `title`: Note title (required, validated in BLoC)
- `content`: Note content (can be empty)
- `createdAt`: Creation timestamp
- `updatedAt`: Last modification timestamp

#### `bible_verse.dart`

**Purpose**: Core business object representing a Bible verse

```dart
class BibleVerse extends Equatable {
  final String reference;     // "John 3:16"
  final String text;          // "For God so loved..."
  final String book;          // "John"
  final int chapter;          // 3
  final int verse;            // 16

  const BibleVerse({
    required this.reference,
    required this.text,
    required this.book,
    required this.chapter,
    required this.verse,
  });

  @override
  List<Object> get props => [reference, text, book, chapter, verse];
}
```

**Why Separate Fields:**

- `reference`: Human-readable format
- `book`, `chapter`, `verse`: Structured data for queries/comparison

#### `bible_reference.dart`

**Purpose**: Detected Bible reference (before fetching verse text)

```dart
class BibleReference extends Equatable {
  final String book;
  final int chapter;
  final int? startVerse;
  final int? endVerse;
  final String originalText;

  const BibleReference({
    required this.book,
    required this.chapter,
    this.startVerse,
    this.endVerse,
    required this.originalText,
  });

  bool get isChapterOnly => startVerse == null && endVerse == null;
  bool get isVerseRange => startVerse != null && endVerse != null && startVerse != endVerse;

  String get formatted {
    if (isChapterOnly) return '$book $chapter';
    if (isVerseRange) return '$book $chapter:$startVerse-$endVerse';
    return '$book $chapter:$startVerse';
  }

  @override
  List<Object?> get props => [book, chapter, startVerse, endVerse, originalText];
}
```

**Supports:**

- Chapter-only: "1 Cor 13" → `BibleReference(book: "1 Corinthians", chapter: 13, startVerse: null)`
- Single verse: "John 3:16" → `BibleReference(book: "John", chapter: 3, startVerse: 16, endVerse: 16)`
- Verse range: "John 3:16-17" → `BibleReference(book: "John", chapter: 3, startVerse: 16, endVerse: 17)`

**Getters:**

- `isChapterOnly`: Check if no verses specified
- `isVerseRange`: Check if range of verses
- `formatted`: Convert back to readable string

---

### 📁 `domain/repositories/`

Repository interfaces define WHAT operations are available, not HOW they work.

#### `note_repository.dart`

**Purpose**: Contract for note data operations

```dart
abstract class NoteRepository {
  Future<List<Note>> getNotes({String? orderBy, bool ascending = false});
  Future<Note> getNoteById(String id);
  Future<void> addNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
  Future<int> getNotesCount();
  Future<List<Note>> searchNotes(String query);
}
```

**Benefits of Interface:**

- Domain layer doesn't depend on data layer
- Can have multiple implementations (SQLite, Firebase, mock)
- Easy to test with fake implementations
- Clear API contract

**Naming Convention:**

- `get*`: Read operations
- `add*`: Create operations
- `update*`: Modify operations
- `delete*`: Remove operations

#### `bible_repository.dart`

**Purpose**: Contract for Bible verse operations

```dart
abstract class BibleRepository {
  Future<BibleVerse> getVerse(String reference);
  Future<List<BibleVerse>> getMultipleVerses(List<String> references);
  List<String> detectVerseReferences(String text);
}
```

**Method Signatures:**

- `getVerse`: Fetch single verse by reference
- `getMultipleVerses`: Fetch multiple verses (batch operation)
- `detectVerseReferences`: Parse text for references (could be moved to util)

---

### 📁 `domain/usecases/`

Use cases are single-purpose business logic operations. Each use case does ONE thing.

#### `get_notes.dart`

**Purpose**: Retrieve all notes from repository

```dart
class GetNotes implements UseCase<List<Note>, NoParams> {
  final NoteRepository repository;

  GetNotes(this.repository);

  @override
  Future<List<Note>> call(NoParams params) async {
    return await repository.getNotes();
  }
}
```

**Why So Simple:**

- Currently just delegates to repository
- Could add business logic (filtering, sorting, validation)
- Single Responsibility Principle
- Easy to test

**Could Be Enhanced:**

```dart
@override
Future<List<Note>> call(NoParams params) async {
  final notes = await repository.getNotes();

  // Business logic examples:
  // - Filter out empty notes
  // - Sort by custom rules
  // - Validate data integrity
  // - Add default notes if empty

  return notes.where((note) => note.title.isNotEmpty).toList();
}
```

#### `add_note.dart`

**Purpose**: Add new note with validation

```dart
class AddNote implements UseCase<void, Note> {
  final NoteRepository repository;

  AddNote(this.repository);

  @override
  Future<void> call(Note params) async {
    // Could add validation here:
    // if (params.title.isEmpty) throw ValidationException('Title required');

    return await repository.addNote(params);
  }
}
```

**Validation Options:**

1. Here in use case (business rules)
2. In BLoC (UI validation)
3. In entity constructor (data integrity)

#### `update_note.dart`

**Purpose**: Update existing note

```dart
class UpdateNote implements UseCase<void, Note> {
  final NoteRepository repository;

  UpdateNote(this.repository);

  @override
  Future<void> call(Note params) async {
    // Could check if note exists
    // Could validate changes
    // Could track revision history

    return await repository.updateNote(params);
  }
}
```

#### `delete_note.dart`

**Purpose**: Delete note by ID

```dart
class DeleteNote implements UseCase<void, String> {
  final NoteRepository repository;

  DeleteNote(this.repository);

  @override
  Future<void> call(String params) async {
    // Could check permissions
    // Could soft-delete (mark as deleted)
    // Could backup before delete

    return await repository.deleteNote(params);
  }
}
```

#### `get_note_by_id.dart`

**Purpose**: Retrieve single note

```dart
class GetNoteById implements UseCase<Note, String> {
  final NoteRepository repository;

  GetNoteById(this.repository);

  @override
  Future<Note> call(String params) async {
    return await repository.getNoteById(params);
  }
}
```

#### `search_notes.dart`

**Purpose**: Search notes by query

```dart
class SearchNotes implements UseCase<List<Note>, String> {
  final NoteRepository repository;

  SearchNotes(this.repository);

  @override
  Future<List<Note>> call(String params) async {
    // Could add business logic:
    // - Minimum query length
    // - Search history
    // - Search suggestions
    // - Relevance scoring

    return await repository.searchNotes(params);
  }
}
```

#### `detect_bible_verses.dart`

**Purpose**: Detect Bible references in text

```dart
class DetectBibleVerses implements UseCase<List<String>, String> {
  final BibleRepository repository;

  DetectBibleVerses(this.repository);

  @override
  Future<List<String>> call(String params) async {
    return repository.detectVerseReferences(params);
  }
}
```

#### `get_verse.dart`

**Purpose**: Fetch Bible verse content

```dart
class GetVerse implements UseCase<BibleVerse, String> {
  final BibleRepository repository;

  GetVerse(this.repository);

  @override
  Future<BibleVerse> call(String params) async {
    return await repository.getVerse(params);
  }
}
```

---

### 📁 `domain/utils/`

Domain-specific utilities that contain business logic.

#### `bible_reference_parser.dart`

**Purpose**: Parse text to detect Bible verse references

```dart
class BibleReferenceParser {
  // Book name database (66+ books with abbreviations)
  static final Map<String, String> _bookNames = {
    'genesis': 'Genesis',
    'gen': 'Genesis',
    'john': 'John',
    'jhn': 'John',
    '1 corinthians': '1 Corinthians',
    '1cor': '1 Corinthians',
    // ... 200+ mappings
  };

  // Regex for verse references (e.g., "John 3:16")
  static final RegExp _versePattern = RegExp(
    r'\b(?:(?:1|2|3)\s+)?'              // Optional number (1, 2, 3)
    r'([A-Z][a-z]+(?:\s+of\s+[A-Z][a-z]+)?)'  // Book name (capitalized)
    r'\s+'                               // Required space
    r'(\d+)'                            // Chapter
    r'(?:\s*[:v]\s*|\s+vs?\.?\s+)'      // Separator (: or v or vs)
    r'(\d+)'                            // Start verse
    r'(?:\s*[-–—]\s*(\d+))?'            // Optional end verse
    r'\b',
    caseSensitive: true,
  );

  // Regex for chapter-only (e.g., "1 Cor 13")
  static final RegExp _chapterOnlyPattern = RegExp(...);

  static List<BibleReference> parse(String text) {
    final List<BibleReference> references = [];

    // Find verse references
    final verseMatches = _versePattern.allMatches(text);
    for (final match in verseMatches) {
      final bookPart = _extractBookName(match.group(0)!);
      final normalizedBook = _normalizeBookName(bookPart);

      if (normalizedBook != null) {
        references.add(BibleReference(
          book: normalizedBook,
          chapter: int.parse(match.group(2)!),
          startVerse: int.parse(match.group(3)!),
          endVerse: match.group(4) != null ? int.parse(match.group(4)!) : null,
          originalText: match.group(0)!,
        ));
      }
    }

    // Find chapter-only references
    // ... similar logic

    return references;
  }

  static String? _normalizeBookName(String bookName) {
    return _bookNames[bookName.toLowerCase()];
  }

  static bool isValidBookName(String bookName) {
    return _normalizeBookName(bookName) != null;
  }
}
```

**Key Features:**

1. **Strict Capitalization**: Only matches "John 3:16", not "john 3:16"
   - Prevents false positives ("mark said hello" vs "Mark 1:1")

2. **Multiple Separators**: Supports `:`, `v`, `vs`
   - "John 3:16"
   - "Gen 1v1"
   - "Gen 1vs1"

3. **Verse Ranges**: "John 3:16-17"

4. **Chapter-Only**: "1 Cor 13"

5. **Numbered Books**: "1 Corinthians", "2 Kings", "3 John"

6. **Abbreviation Mapping**: "Matt" → "Matthew", "Gen" → "Genesis"

**Why In Domain:**

- Contains business rules (what constitutes a valid reference)
- No external dependencies
- Pure Dart logic
- Reusable across features

**Regex Breakdown:**

```regex
\b                                      # Word boundary
(?:(?:1|2|3)\s+)?                      # Optional book number
([A-Z][a-z]+(?:\s+of\s+[A-Z][a-z]+)?)  # Book name (capitalized)
\s+                                     # Required space
(\d+)                                   # Chapter number
(?:\s*[:v]\s*|\s+vs?\.?\s+)            # Separator
(\d+)                                   # Start verse
(?:\s*[-–—]\s*(\d+))?                  # Optional end verse
\b                                      # Word boundary
```

---

## 🎨 `lib/presentation/` - Presentation Layer

Everything the user sees and interacts with. Contains widgets, screens, and state management.

```
presentation/
├── bloc/                   # State management (BLoC pattern)
├── pages/                  # Screen widgets
└── widgets/               # Reusable UI components
```

### 📁 `presentation/bloc/`

BLoCs manage state and business logic for UI components.

```
bloc/
├── notes/                  # Notes feature BLoC
├── bible_toolkit/         # Verse detection BLoC
└── verse_fetch/           # Verse fetching BLoC
```

#### 📁 `bloc/notes/`

**Files:**

- `notes_event.dart` - Events (user actions)
- `notes_state.dart` - States (UI representations)
- `notes_bloc.dart` - Business logic (event → state)

##### `notes_event.dart`

```dart
abstract class NotesEvent extends Equatable {
  const NotesEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotes extends NotesEvent {
  final String? orderBy;
  final bool ascending;
  const LoadNotes({this.orderBy, this.ascending = false});
  @override
  List<Object?> get props => [orderBy, ascending];
}

class AddNoteEvent extends NotesEvent {
  final Note note;
  const AddNoteEvent(this.note);
  @override
  List<Object> get props => [note];
}

class UpdateNoteEvent extends NotesEvent {
  final Note note;
  const UpdateNoteEvent(this.note);
  @override
  List<Object> get props => [note];
}

class DeleteNoteEvent extends NotesEvent {
  final String noteId;
  const DeleteNoteEvent(this.noteId);
  @override
  List<Object> get props => [noteId];
}

class SearchNotesEvent extends NotesEvent {
  final String query;
  const SearchNotesEvent(this.query);
  @override
  List<Object> get props => [query];
}
```

**Events Represent:**

- User actions
- System events
- External triggers

**Why Extend Equatable:**

- BLoC can compare events
- Prevents duplicate event processing
- Makes debugging easier

##### `notes_state.dart`

```dart
abstract class NotesState extends Equatable {
  const NotesState();
  @override
  List<Object> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;
  final bool isSearching;

  const NotesLoaded(this.notes, {this.isSearching = false});

  @override
  List<Object> get props => [notes, isSearching];
}

class NoteOperationSuccess extends NotesState {
  final String message;
  const NoteOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class NotesError extends NotesState {
  final String message;
  const NotesError(this.message);
  @override
  List<Object> get props => [message];
}
```

**States Represent:**

- Current UI state
- What user should see
- Loading/error/success conditions

**State Flow:**

```
NotesInitial (app starts)
  ↓ LoadNotes event
NotesLoading (showing spinner)
  ↓ success
NotesLoaded (showing list)
  ↓ AddNoteEvent
NotesLoading (showing spinner)
  ↓ success
NoteOperationSuccess (showing success message)
  ↓ auto-reload
NotesLoaded (updated list)
```

##### `notes_bloc.dart`

```dart
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetNotes getNotes;
  final AddNote addNote;
  final UpdateNote updateNote;
  final DeleteNote deleteNote;
  final SearchNotes searchNotes;

  NotesBloc({
    required this.getNotes,
    required this.addNote,
    required this.updateNote,
    required this.deleteNote,
    required this.searchNotes,
  }) : super(NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<SearchNotesEvent>(_onSearchNotes);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final notes = await getNotes(NoParams());
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onAddNote(AddNoteEvent event, Emitter<NotesState> emit) async {
    try {
      await addNote(event.note);
      emit(const NoteOperationSuccess('Note saved successfully'));
      add(const LoadNotes());  // Auto-reload
    } catch (e) {
      emit(NotesError('Failed to save note: ${e.toString()}'));
    }
  }

  // ... more event handlers
}
```

**BLoC Responsibilities:**

1. Listen for events
2. Call appropriate use case
3. Emit new state based on result
4. Handle errors gracefully

**Benefits:**

- Testable (mock use cases)
- Predictable state changes
- Separation from UI
- Reusable across screens

#### 📁 `bloc/bible_toolkit/`

Handles verse detection with debouncing.

##### `bible_toolkit_bloc.dart`

```dart
class BibleToolkitBloc extends Bloc<BibleToolkitEvent, BibleToolkitState> {
  final DetectBibleVerses detectBibleVerses;
  final GetVerse getVerse;

  BibleToolkitBloc({
    required this.detectBibleVerses,
    required this.getVerse,
  }) : super(BibleToolkitInitial()) {
    on<DetectVersesInText>(
      _onDetectVerses,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .asyncExpand(mapper),
    );
  }

  Future<void> _onDetectVerses(
    DetectVersesInText event,
    Emitter<BibleToolkitState> emit,
  ) async {
    try {
      final references = BibleReferenceParser.parse(event.text);
      final verses = references.map((ref) => ref.formatted).toList();
      emit(VersesDetected(verses));
    } catch (e) {
      emit(const VersesDetected([]));
    }
  }
}
```

**Key Feature: Debouncing**

```dart
transformer: (events, mapper) => events
    .debounceTime(const Duration(milliseconds: 500))
    .asyncExpand(mapper)
```

**How Debouncing Works:**

```
User types "J" → DetectVersesInText("J")
Wait 500ms... user still typing
User types "o" → DetectVersesInText("Jo")
Wait 500ms... user still typing
User types "h" → DetectVersesInText("Joh")
Wait 500ms... user still typing
User types "n" → DetectVersesInText("John")
Wait 500ms... user paused
→ Process "John" (no match yet)

User types " " → DetectVersesInText("John ")
Wait 500ms...
User types "3" → DetectVersesInText("John 3")
Wait 500ms...
User types ":" → DetectVersesInText("John 3:")
Wait 500ms...
User types "1" → DetectVersesInText("John 3:1")
Wait 500ms...
User types "6" → DetectVersesInText("John 3:16")
Wait 500ms... user paused
→ Process "John 3:16" (MATCH FOUND!)
→ Emit VersesDetected(["John 3:16"])
→ UI shows preview button
```

**Benefits:**

- Doesn't lag while typing
- Saves CPU/battery
- Better user experience
- Only processes when user pauses

#### 📁 `bloc/verse_fetch/`

Fetches verse content from API.

##### `verse_fetch_bloc.dart`

```dart
class VerseFetchBloc extends Bloc<VerseFetchEvent, VerseFetchState> {
  final GetVerse getVerse;

  VerseFetchBloc({required this.getVerse}) : super(VerseFetchInitial()) {
    on<FetchVerseEvent>(_onFetchVerse);
  }

  Future<void> _onFetchVerse(
    FetchVerseEvent event,
    Emitter<VerseFetchState> emit,
  ) async {
    emit(VerseFetchLoading());

    try {
      final verse = await getVerse(event.reference);
      emit(VerseFetchLoaded(verse));
    } catch (e) {
      emit(VerseFetchError(_getErrorMessage(e)));
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('internet')) {
      return 'No internet connection...';
    } else if (errorString.contains('not found')) {
      return 'Verse not found...';
    } else if (errorString.contains('timeout')) {
      return 'Connection timeout...';
    }
    return 'Unable to load verse...';
  }
}
```

**Error Message Mapping:**

- Makes technical errors user-friendly
- Provides actionable information
- Consistent error experience

---

### 📁 `presentation/pages/`

Full-screen widgets representing app screens.

#### `notes_list_page.dart`

**Purpose**: Main screen showing all notes

**Structure:**

```dart
class NotesListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<NotesBloc>()..add(const LoadNotes()),
      child: Scaffold(
        appBar: AppBar(...),
        body: BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {
            if (state is NotesLoading) return CircularProgressIndicator();
            if (state is NotesLoaded) return _buildNotesList(state.notes);
            if (state is NotesError) return ErrorWidget(state.message);
            return SizedBox();
          },
        ),
        floatingActionButton: FloatingActionButton(...),
      ),
    );
  }
}
```

**Features:**

1. **BLoC Integration**

   ```dart
   BlocProvider(
     create: (_) => di.sl<NotesBloc>()..add(const LoadNotes()),
     // ^ Creates BLoC and immediately loads notes
   ```

2. **State-Based UI**

   ```dart
   BlocBuilder<NotesBloc, NotesState>(
     builder: (context, state) {
       // Different UI for different states
     }
   )
   ```

3. **Empty State**

   ```dart
   if (state.notes.isEmpty) {
     return Center(
       child: Column(
         children: [
           Icon(Icons.note_add, size: 64),
           Text('No notes yet'),
           Text('Tap + to create your first note'),
         ],
       ),
     );
   }
   ```

4. **Swipe to Delete**

   ```dart
   Dismissible(
     key: Key(note.id),
     direction: DismissDirection.endToStart,
     confirmDismiss: (direction) async {
       return await showDialog<bool>(
         context: context,
         builder: (context) => AlertDialog(
           title: Text('Delete Note'),
           content: Text('Are you sure?'),
           actions: [
             TextButton(onPressed: () => Navigator.pop(context, false)),
             TextButton(onPressed: () => Navigator.pop(context, true)),
           ],
         ),
       );
     },
     onDismissed: (direction) {
       context.read<NotesBloc>().add(DeleteNoteEvent(note.id));
     },
     background: Container(color: Colors.red, child: Icon(Icons.delete)),
     child: ListTile(...),
   )
   ```

5. **Search Dialog**

   ```dart
   void _showSearchDialog(BuildContext context) {
     showDialog(
       context: context,
       builder: (dialogContext) => AlertDialog(
         title: Text('Search Notes'),
         content: TextField(
           onSubmitted: (query) {
             Navigator.of(dialogContext).pop();
             context.read<NotesBloc>().add(SearchNotesEvent(query));
           },
         ),
       ),
     );
   }
   ```

6. **Navigation with Result**
   ```dart
   onTap: () async {
     final result = await Navigator.push(
       context,
       MaterialPageRoute(builder: (_) => SermonEditorScreen(note: note)),
     );
     if (result == true) {
       context.read<NotesBloc>().add(const LoadNotes());
     }
   }
   ```

#### `sermon_editor_screen.dart`

**Purpose**: Create/edit sermon notes with verse detection

**Structure:**

```dart
class SermonEditorScreen extends StatefulWidget {
  final Note? note;  // null = new note, not null = edit existing

  @override
  State<SermonEditorScreen> createState() => _SermonEditorScreenState();
}

class _SermonEditorScreenState extends State<SermonEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late FocusNode _contentFocusNode;
  late NotesBloc _notesBloc;

  List<String> _detectedVerses = [];
  Offset? _previewButtonPosition;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _contentFocusNode = FocusNode();
    _notesBloc = di.sl<NotesBloc>();

    _contentController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    // Update preview button position when cursor moves
    if (_detectedVerses.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updatePreviewButtonPosition();
      });
    }
  }

  String _getCurrentLine() {
    final text = _contentController.text;
    final cursorPosition = _contentController.selection.baseOffset;

    if (cursorPosition < 0 || text.isEmpty) return '';

    // Find line boundaries
    int lineStart = text.lastIndexOf('\n', cursorPosition - 1) + 1;
    int lineEnd = text.indexOf('\n', cursorPosition);
    if (lineEnd == -1) lineEnd = text.length;

    return text.substring(lineStart, lineEnd);
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final now = DateTime.now();
    final note = Note(
      id: widget.note?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      content: _contentController.text,
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.note == null) {
      _notesBloc.add(AddNoteEvent(note));
    } else {
      _notesBloc.add(UpdateNoteEvent(note));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<BibleToolkitBloc>()),
        BlocProvider.value(value: _notesBloc),
      ],
      child: BlocListener<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NoteOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop(true);
          } else if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
            actions: [
              IconButton(icon: Icon(Icons.save), onPressed: _saveNote),
            ],
          ),
          body: Stack(
            children: [
              _buildEditorContent(),
              if (_detectedVerses.isNotEmpty) _buildFloatingPreviewButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditorContent() {
    return Column(
      children: [
        // Title field
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Sermon Title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        Divider(),

        // Content field
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _contentController,
              focusNode: _contentFocusNode,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'Start typing...\n\nTip: Type Bible references like "John 3:16"',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                final currentLine = _getCurrentLine();
                context.read<BibleToolkitBloc>().add(DetectVersesInText(currentLine));
              },
            ),
          ),
        ),

        // Detection indicator
        BlocBuilder<BibleToolkitBloc, BibleToolkitState>(
          builder: (context, state) {
            if (state is VersesDetected && state.verses.isNotEmpty) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    Icon(Icons.book, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${state.verses.length} verse(s) detected: ${state.verses.join(", ")}',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
```

**Key Features:**

1. **TextField Configuration**

   ```dart
   TextField(
     maxLines: null,        // Allow unlimited lines
     expands: true,         // Take all available space
     textAlignVertical: TextAlignVertical.top,  // Start at top
   )
   ```

2. **Current Line Detection**
   - Only parses the line where cursor is
   - Improves performance
   - More relevant results

3. **Real-time Verse Detection**

   ```dart
   onChanged: (text) {
     final currentLine = _getCurrentLine();
     context.read<BibleToolkitBloc>().add(DetectVersesInText(currentLine));
     // Debounced automatically by BLoC
   }
   ```

4. **UUID Generation for New Notes**

   ```dart
   id: widget.note?.id ?? const Uuid().v4()
   // Use existing ID or generate new one
   ```

5. **Validation**

   ```dart
   if (_titleController.text.trim().isEmpty) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Please enter a title')),
     );
     return;
   }
   ```

6. **Navigation with Result**
   ```dart
   Navigator.of(context).pop(true);  // true = note was saved
   ```

---

### 📁 `presentation/widgets/`

Reusable UI components.

#### `verse_preview_button.dart`

**Purpose**: Floating button to preview detected verses

```dart
class VersePreviewButton extends StatelessWidget {
  final List<String> verses;
  final Function(String) onPreview;

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) return SizedBox.shrink();

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: verses.length == 1
            ? _buildSingleVerseButton(verses.first)
            : _buildMultipleVersesButton(),
      ),
    );
  }

  Widget _buildSingleVerseButton(String verse) {
    return InkWell(
      onTap: () => onPreview(verse),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.visibility, color: Colors.white),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Preview Verse', style: TextStyle(color: Colors.white)),
                Text(verse, style: TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleVersesButton() {
    return PopupMenuButton<String>(
      onSelected: onPreview,
      itemBuilder: (context) => verses.map((verse) {
        return PopupMenuItem(
          value: verse,
          child: Row(
            children: [
              Icon(Icons.book, size: 16),
              SizedBox(width: 8),
              Text(verse),
            ],
          ),
        );
      }).toList(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.visibility, color: Colors.white),
            SizedBox(width: 8),
            Text('Preview Verses (${verses.length})', style: TextStyle(color: Colors.white)),
            Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
```

**Features:**

- Single verse: Direct button
- Multiple verses: Dropdown menu
- Gradient background
- Material elevation (shadow)

#### `verse_preview_dialog.dart`

**Purpose**: Modal dialog showing verse content

```dart
class VersePreviewDialog extends StatelessWidget {
  final String verseReference;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<VerseFetchBloc>()..add(FetchVerseEvent(verseReference)),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            children: [
              _buildHeader(context),
              Flexible(child: _buildContent(context)),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.book),
          SizedBox(width: 12),
          Expanded(child: Text(verseReference, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<VerseFetchBloc, VerseFetchState>(
      builder: (context, state) {
        if (state is VerseFetchLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is VerseFetchLoaded) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.verse.text, style: TextStyle(fontSize: 16, height: 1.6)),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${state.verse.book} ${state.verse.chapter}:${state.verse.verse}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          );
        } else if (state is VerseFetchError) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(state.message),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<VerseFetchBloc>().add(FetchVerseEvent(verseReference));
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Retry'),
                ),
              ],
            ),
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    return BlocBuilder<VerseFetchBloc, VerseFetchState>(
      builder: (context, state) {
        if (state is! VerseFetchLoaded) return SizedBox.shrink();

        return Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                    text: '${state.verse.reference}\n\n${state.verse.text}',
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Verse copied to clipboard')),
                  );
                },
                icon: Icon(Icons.copy),
                label: Text('Copy'),
              ),
              SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Insert verse into note at cursor position
                  Navigator.pop(context);
                },
                icon: Icon(Icons.add),
                label: Text('Insert'),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

**Features:**

1. Loading state (spinner)
2. Success state (verse display)
3. Error state (with retry button)
4. Copy to clipboard
5. Insert into note (placeholder)

---

## 📂 The `test/` Directory

```
test/
├── data/
│   └── datasources/
│       └── bible_api_service_test.dart
└── domain/
    └── utils/
        └── bible_reference_parser_test.dart
```

### Test Structure

Tests mirror the `lib/` directory structure for easy navigation.

#### `test/data/datasources/bible_api_service_test.dart`

```dart
@GenerateMocks([http.Client])
void main() {
  late BibleApiServiceImpl service;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    service = BibleApiServiceImpl(client: mockClient);
  });

  group('BibleApiService - fetchVerseText', () {
    test('should return BibleVerseModel when API call is successful', () async {
      // Arrange
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(jsonResponse, 200));

      // Act
      final result = await service.fetchVerseText('John 3:16');

      // Assert
      expect(result, isA<BibleVerseModel>());
      expect(result.reference, equals('John 3:16'));
    });

    test('should throw NetworkException when there is no internet', () async {
      // Arrange
      when(mockClient.get(any)).thenThrow(SocketException('No internet'));

      // Act & Assert
      expect(
        () => service.fetchVerseText('John 3:16'),
        throwsA(isA<NetworkException>()),
      );
    });

    // ... more tests
  });
}
```

**Test Pattern: AAA**

- **Arrange**: Set up test data and mocks
- **Act**: Execute the code being tested
- **Assert**: Verify the results

**Mockito:**

- `@GenerateMocks([http.Client])`: Generate mock class
- `when(mock.method()).thenAnswer()`: Define mock behavior
- `verify(mock.method())`: Verify method was called

#### `test/domain/utils/bible_reference_parser_test.dart`

```dart
void main() {
  group('BibleReferenceParser', () {
    test('should parse simple verse reference', () {
      // Arrange
      const text = 'Today we read John 3:16 in church.';

      // Act
      final results = BibleReferenceParser.parse(text);

      // Assert
      expect(results, hasLength(1));
      expect(results[0].book, equals('John'));
      expect(results[0].chapter, equals(3));
      expect(results[0].startVerse, equals(16));
    });

    test('should NOT parse names without chapter/verse', () {
      // Arrange
      const text = 'Mark said hello to John yesterday.';

      // Act
      final results = BibleReferenceParser.parse(text);

      // Assert
      expect(results, isEmpty);
    });

    // ... more tests
  });
}
```

**Why Test Parser:**

- Critical feature (false positives/negatives are bad UX)
- Complex regex logic
- Many edge cases
- Easy to break with changes

---

## 🔄 Data Flow Summary

### Creating a Note

```
User Interface (SermonEditorScreen)
  ↓ user taps save
NotesBloc receives AddNoteEvent
  ↓
AddNote Use Case
  ↓
NoteRepository.addNote()
  ↓
NoteRepositoryImpl coordinates
  ↓
NoteLocalDataSource.insertNote()
  ↓
SQLite database.insert()
  ↓ success
Database returns
  ↑
NoteLocalDataSource returns
  ↑
NoteRepository returns
  ↑
Use Case returns
  ↑
BLoC emits NoteOperationSuccess
  ↑
UI shows SnackBar and navigates back
```

### Detecting & Previewing a Verse

```
User types in TextField
  ↓ onChange
Extract current line
  ↓
Dispatch DetectVersesInText event
  ↓
BibleToolkitBloc (with 500ms debounce)
  ↓ after pause
BibleReferenceParser.parse()
  ↓ regex matching
Returns List<BibleReference>
  ↓
Emit VersesDetected state
  ↓
UI shows VersePreviewButton
  ↓ user taps
Show VersePreviewDialog
  ↓
VerseFetchBloc receives FetchVerseEvent
  ↓
GetVerse Use Case
  ↓
BibleRepository.getVerse()
  ↓
BibleRemoteDataSource.fetchVerse()
  ↓
BibleApiService.fetchVerseText()
  ↓
HTTP GET to bible-api.com
  ↓ response
Parse JSON to BibleVerseModel
  ↑
Return through layers
  ↑
VerseFetchBloc emits VerseFetchLoaded
  ↑
UI displays verse text in dialog
```

---

## 🎯 Why This Structure Works

### 1. **Testability**

Each layer can be tested independently:

- UI tests: Mock BLoCs
- BLoC tests: Mock use cases
- Use case tests: Mock repositories
- Repository tests: Mock data sources
- Data source tests: Mock HTTP client / database

### 2. **Maintainability**

Clear separation of concerns:

- Change database? Only touch data layer
- Change UI framework? Only touch presentation layer
- Add feature? Add use case, update BLoC

### 3. **Scalability**

Easy to add new features:

- New data source? Implement interface
- New screen? Create new BLoC and page
- New business rule? Add use case

### 4. **Team Collaboration**

Different developers can work on different layers:

- Backend dev: Data layer
- UI dev: Presentation layer
- Business analyst: Domain layer
- Everyone: Follows same patterns

### 5. **Code Reuse**

Shared infrastructure:

- Use cases reusable across BLoCs
- Data sources reusable across repositories
- Entities reusable across layers
- Utils reusable everywhere

---

## 📚 Conclusion

The SermonNotes file structure demonstrates **Clean Architecture** principles applied to a real Flutter app:

- **`core/`**: Shared infrastructure (DI, errors, base classes)
- **`data/`**: How to get/store data (API, database, caching)
- **`domain/`**: What the app does (business logic, entities, contracts)
- **`presentation/`**: How users interact (UI, state management, widgets)
- **`test/`**: Quality assurance (unit tests, mocks, coverage)

Each file has a single, clear purpose. Each folder groups related functionality. The structure is predictable, navigable, and maintainable.

This architecture allows the app to grow from a simple note-taking app to a comprehensive sermon preparation tool without major refactoring. 🚀
