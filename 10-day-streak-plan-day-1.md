# 10-Day Flutter Streak Plan: Day 1

## 📅 Day 1: Project Setup & Architecture Foundation

### 🎯 Learning Goals

- Understand Clean Architecture principles
- Set up folder structure following best practices
- Implement Dependency Injection foundation
- Learn error handling patterns
- Configure pubspec.yaml with essential dependencies

### 📝 What You'll Build

Today you'll create the architectural foundation of your app. This is the skeleton on which everything else will be built. Think of it as laying the blueprint for a house before building walls and rooms.

---

### Step 1: Create Folder Structure

Create the following folders in your Flutter project's `lib/` directory:

```
lib/
├── core/              # Shared utilities, DI, errors
│   ├── constants/     # API URLs, timeouts, etc.
│   ├── di/           # Dependency Injection
│   ├── error/        # Exceptions and Failures
│   └── usecases/     # Base UseCase abstract class
├── data/             # Data layer (database, API)
│   ├── datasources/  # Data sources (local & remote)
│   ├── models/       # Data models
│   └── repositories/ # Repository implementations
├── domain/           # Business logic layer
│   ├── entities/     # Core business objects
│   ├── repositories/ # Repository interfaces
│   ├── usecases/     # Business operations
│   └── utils/        # Business utilities
└── presentation/     # UI layer
    ├── bloc/         # BLoC state management
    ├── pages/        # Full-screen widgets
    └── widgets/      # Reusable UI components
```

**Why this structure?**

- **Separation of Concerns**: Each layer has one responsibility
- **Testability**: Easy to test each layer independently
- **Maintainability**: Clear organization makes code easier to find
- **Scalability**: Easy to add new features

---

### Step 2: Create pubspec.yaml Dependencies

Update your `pubspec.yaml` with these dependencies:

```yaml
name: sermon_notes
description: "A sermon note-taking app with Bible verse detection"
publish_to: "none"

version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5

  # Dependency Injection
  get_it: ^7.6.4

  # Database
  sqflite: ^2.3.0
  path: ^1.8.3

  # Networking
  http: ^1.1.0

  # Utilities
  uuid: ^4.2.1
  rxdart: ^0.27.7

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^3.0.0
  mockito: ^5.4.2
  build_runner: ^2.4.6
```

Run `flutter pub get` to install dependencies.

**What Each Package Does:**

- `flutter_bloc`: State management using BLoC pattern
- `equatable`: Compare objects without boilerplate
- `get_it`: Service locator for dependency injection
- `sqflite`: SQLite database
- `http`: HTTP client for API calls
- `uuid`: Generate unique IDs
- `rxdart`: Reactive extensions for Dart
- `mockito`: Mocking for unit tests

---

### Step 3: Create Error Handling Structure

**File**: `lib/core/error/exceptions.dart`

```dart
/// Exception thrown when accessing cached data that doesn't exist
class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when database operation fails
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}

/// Exception thrown when network request fails
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when API returns 404
class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when API returns 5xx error
class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}
```

**File**: `lib/core/error/failures.dart`

```dart
import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Database operation failed
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Network operation failed
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// API returned not found
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Server returned error
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
```

**🎓 What You're Learning:**

- **Exceptions**: Technical errors from the framework/libraries
- **Failures**: Business errors used in domain layer
- **Separation**: Data layer throws exceptions, converts to failures for domain
- **Type Safety**: Specific exceptions for different scenarios

---

### Step 4: Create Base UseCase

**File**: `lib/core/usecases/usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base class for all use cases
/// Type: Return type of the use case
/// Params: Parameters for the use case
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use NoParams when use case takes no parameters
class NoParams {}
```

**🎓 What You're Learning:**

- **Either Type**: Represents success (Right) or failure (Left)
- **Template Pattern**: Base class for all operations
- **Generic Programming**: Reusable for any return type and parameters

> **Note**: Add `dartz: ^0.10.1` to pubspec.yaml for Either type

---

### Step 5: Create Dependency Injection Container

**File**: `lib/core/di/injection_container.dart`

```dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  // Bloc will be registered later when we create them
  // Data sources will be registered later when we create them
  // Use cases will be registered later when we create them
}
```

**🎓 What You're Learning:**

- **Service Locator**: GetIt locates services throughout the app
- **Lazy Singleton**: Dependencies created once and reused
- **Factory**: New instance created each time (good for BLoCs)
- **Initialization**: All dependencies registered in one place

---

### Step 6: Create API Constants

**File**: `lib/core/constants/api_constants.dart`

```dart
class ApiConstants {
  // Bible API endpoints
  static const String baseUrl = 'https://api.scripture.api.bible/v1/bibles/de4e12af7f28f599-02/verses';

  // Timeouts
  static const int apiTimeoutSeconds = 10;

  // Error messages
  static const String noInternetMessage = 'No internet connection';
  static const String serverErrorMessage = 'Server error occurred';
  static const String cacheErrorMessage = 'Error reading from cache';

  // Database
  static const String databaseName = 'sermon_notes.db';
  static const int databaseVersion = 1;
}
```

---

### Step 7: Update main.dart

**File**: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'core/di/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SermonNotes',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: const Placeholder(), // Will be replaced tomorrow
    );
  }
}
```

---

### 📦 Commit Your Work

```bash
git add .
git commit -m "Day 1: Initial project setup with Clean Architecture structure

- Created folder structure (core, data, domain, presentation)
- Set up dependency injection foundation with GetIt
- Implemented base UseCase pattern
- Added error handling (exceptions and failures)
- Configured pubspec.yaml with essential dependencies
- Created API constants and main.dart

Learning: Understanding separation of concerns and why Clean Architecture matters for maintainability."

git push origin main
```

---

### 📖 Blog Entry: Day 1

**Title**: "Starting the 10-Day Flutter Challenge: Building a Sermon Notes App"

**What I'm Building:**
I'm starting a 10-day streak to build a complete Flutter app while learning best practices. The app is called **SermonNotes** - a tool for taking sermon notes with intelligent Bible verse detection.

**Today's Work:**
Today was all about foundation. I spent the entire day setting up the architectural skeleton:

1. **Created the folder structure** following Clean Architecture principles
2. **Set up 13 dependencies** in pubspec.yaml (BLoC, GetIt, SQLite, HTTP, etc.)
3. **Implemented error handling** with specific exceptions and failures
4. **Created the dependency injection container** to manage all dependencies
5. **Wrote the base UseCase class** that all business operations will extend

**What I Learned:**

1. **Clean Architecture Isn't Magic, It's Organization**:
   - Each layer (Presentation, Domain, Data, Core) has a specific job
   - They communicate through well-defined interfaces
   - This makes the code predictable and testable

2. **Exceptions vs Failures is Crucial**:

   ```dart
   // Data layer throws exceptions (technical errors)
   throw NetworkException('Connection failed');

   // Domain layer uses failures (business errors)
   return Left(NetworkFailure('Could not fetch data'));
   ```

   This separation lets each layer speak its own language.

3. **GetIt is Powerful**:
   - Acts as a service locator (central registry)
   - Solves the "wiring" problem of dependencies
   - Better than passing constructors everywhere
   - Makes testing incredibly easy (swap real with mock)

4. **Either<Failure, Type> Pattern**:
   - Eliminates exceptions for expected errors
   - Forces error handling (can't forget a catch block)
   - Right = success, Left = failure (intuitive!)

**Why This Matters:**
Most Flutter tutorials skip this foundation and jump straight to UI. But architecture is the difference between:

- ❌ Code that works but is hard to change
- ✅ Code that's easy to test, maintain, and extend

By investing time today in structure, I'll move faster the rest of the week.

**Challenges:**

- Getting the folder structure exactly right took planning
- Understanding the difference between exceptions and failures
- Choosing which packages to use (had to research trade-offs)

**Stats So Far:**

- 📁 Files created: 5
- 📝 Lines of code: ~150
- ⏱️ Time spent: ~60 minutes
- 🚀 Progress: Groundwork complete!

**Tomorrow's Plan:**
Day 2 is about bringing data to life. I'll:

- Create the Note entity
- Set up SQLite database
- Write CRUD operations
- Test with mock data

**Code Highlight of the Day:**

```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
```

This single interface will be the foundation for 8+ use cases over the next week!

---

## 🎯 Key Takeaways

✅ **Foundation matters more than you think**
✅ **Architecture patterns aren't just theory**
✅ **Invest in structure early to move faster later**
✅ **Error handling is a design decision, not an afterthought**

**Next**: Day 2 - Database Setup & Note Entity
