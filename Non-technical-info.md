# SermonNotes App - Technical Explanation

## Overview

**SermonNotes** is a Flutter-based mobile application designed for pastors, Bible study leaders, and Christians to take sermon notes with intelligent Bible verse detection and lookup capabilities. The app automatically detects Bible references as you type (e.g., "John 3:16", "Genesis 1:1") and allows you to preview the full verse text without leaving your note.

## Architecture

The app follows **Clean Architecture** principles with clear separation of concerns across three main layers:

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│  (UI, BLoC State Management, User Interaction)          │
└─────────────────────────────────────────────────────────┘
                          ↓↑
┌─────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                          │
│  (Business Logic, Entities, Use Cases, Interfaces)      │
└─────────────────────────────────────────────────────────┘
                          ↓↑
┌─────────────────────────────────────────────────────────┐
│                     DATA LAYER                           │
│  (Repositories, Data Sources, API/Database Logic)       │
└─────────────────────────────────────────────────────────┘
```

### Key Architectural Benefits

- **Testability**: Each layer can be tested independently
- **Maintainability**: Changes in one layer don't affect others
- **Scalability**: Easy to add new features without breaking existing code
- **Separation of Concerns**: UI logic separated from business logic and data access

---

## Core Features

### 1. **Note Management (CRUD Operations)**

Users can create, read, update, and delete sermon notes stored locally in SQLite database.

**Data Flow:**

```
User Action (UI) → NotesBloc → Use Case → Repository → Local DataSource → SQLite
```

**Key Components:**

- **Entity**: `Note` (id, title, content, createdAt, updatedAt)
- **Use Cases**: `AddNote`, `UpdateNote`, `DeleteNote`, `GetNotes`, `SearchNotes`
- **Storage**: SQLite database with optimized indexes
- **State Management**: BLoC pattern with distinct states (Loading, Loaded, Error)

### 2. **Real-Time Bible Verse Detection**

As users type in the sermon editor, the app automatically detects Bible references using advanced regex patterns.

**Detection Flow:**

```
User Types → Debounce (500ms) → BibleReferenceParser → BibleToolkitBloc → UI Update
```

**How It Works:**

1. **Debouncing**: Uses RxDart's `debounceTime(500ms)` to wait until user pauses typing
2. **Current Line Analysis**: Extracts only the line where the cursor is positioned
3. **Regex Pattern Matching**: Identifies valid Bible references with strict rules:
   - Requires capitalized book names (avoids false positives like "mark said hello")
   - Supports multiple formats: `John 3:16`, `Gen 1vs1`, `2 Kings 4:12`
   - Handles verse ranges: `John 3:16-17`
   - Recognizes chapter-only references: `1 Cor 13`

4. **Comprehensive Book Database**: Maps 66+ Bible book names and common abbreviations
5. **Visual Feedback**: Shows floating "Preview Verse" button when references detected

**Parser Features:**

```dart
// Supported formats:
John 3:16          // Standard format
Gen 1:1            // Abbreviated books
1 Cor 13:4-7       // Numbered books with range
2 Kings 4vs12      // Alternative "vs" separator
Romans 8           // Chapter-only reference
```

### 3. **Bible Verse Preview & Lookup**

Users can preview the full text of detected verses without leaving their note.

**Lookup Flow:**

```
User Clicks Preview → VerseFetchBloc → GetVerse Use Case →
BibleApiService → bible-api.com → Display in Dialog
```

**API Integration:**

- **Endpoint**: `https://bible-api.com/` (free, no authentication required)
- **Error Handling**:
  - Network errors (no internet)
  - 404 Not Found (invalid reference)
  - 500 Server errors
  - Timeout handling (30s limit)
- **Features**: Copy verse to clipboard, insert into note (placeholder)

### 4. **Search Functionality**

Full-text search across all notes by title and content.

**Search Flow:**

```
User Enters Query → SearchNotesEvent → SearchNotes Use Case →
SQL LIKE Query → Filtered Results → UI Update
```

**SQL Query:**

```sql
SELECT * FROM notes
WHERE title LIKE '%query%' OR content LIKE '%query%'
ORDER BY updatedAt DESC
```

---

## Technical Implementation Details

### State Management (BLoC Pattern)

The app uses **BLoC (Business Logic Component)** pattern for predictable state management:

```dart
// Example flow for adding a note:
User taps Save
  → AddNoteEvent dispatched
  → NotesBloc processes event
  → Calls AddNote use case
  → Repository saves to database
  → Emits NoteOperationSuccess state
  → UI shows success message and navigates back
  → Reloads notes list
```

**Active BLoCs:**

1. **NotesBloc**: Handles all note CRUD operations
2. **BibleToolkitBloc**: Manages verse detection with debouncing
3. **VerseFetchBloc**: Fetches individual verse content from API

### Database Schema

```sql
CREATE TABLE notes(
  id TEXT PRIMARY KEY,              -- UUID v4
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  createdAt INTEGER NOT NULL,       -- Unix timestamp (milliseconds)
  updatedAt INTEGER NOT NULL        -- Unix timestamp (milliseconds)
);

-- Performance indexes
CREATE INDEX idx_notes_created_at ON notes(createdAt DESC);
CREATE INDEX idx_notes_updated_at ON notes(updatedAt DESC);
```

### Dependency Injection

Uses **GetIt** service locator pattern for dependency injection:

```dart
// Registration example:
sl.registerFactory(() => NotesBloc(
  getNotes: sl(),      // Automatic dependency resolution
  addNote: sl(),
  updateNote: sl(),
  deleteNote: sl(),
  searchNotes: sl(),
));
```

**Benefits:**

- Decoupled components
- Easy to mock for testing
- Single source of truth for dependencies
- Lazy loading of expensive resources

### Error Handling Strategy

**Three-Layer Error Handling:**

1. **Data Layer**: Throws specific exceptions

   ```dart
   - NetworkException (no internet)
   - NotFoundException (404)
   - ServerException (API errors)
   - CacheException (database errors)
   ```

2. **Domain Layer**: Converts to failures

   ```dart
   - NetworkFailure
   - DatabaseFailure
   ```

3. **Presentation Layer**: Shows user-friendly messages
   ```dart
   - SnackBar notifications
   - Error state displays
   - Retry buttons
   ```

---

## User Interface Components

### Main Screens

1. **Notes List Page** (`notes_list_page.dart`)
   - Displays all saved notes in chronological order
   - Swipe-to-delete with confirmation dialog
   - Search button in app bar
   - Empty state with helpful message
   - Pull-to-refresh (implicit via navigation)

2. **Sermon Editor Screen** (`sermon_editor_screen.dart`)
   - Title input field
   - Multi-line content editor (auto-expanding)
   - Real-time verse detection indicator
   - Floating preview button for detected verses
   - Auto-save on back navigation with validation

### Custom Widgets

1. **VersePreviewButton** (`verse_preview_button.dart`)
   - Appears when verses detected
   - Single verse: Direct preview button
   - Multiple verses: Dropdown menu to select
   - Gradient background with elevation
   - Positioned floating in bottom-right

2. **VersePreviewDialog** (`verse_preview_dialog.dart`)
   - Modal dialog showing verse text
   - Loading state with spinner
   - Error state with retry button
   - Copy to clipboard functionality
   - Insert into note (placeholder)
   - Formatted verse reference display

---

## Data Flow Examples

### Creating a New Note

```
1. User opens SermonEditorScreen (note = null)
2. User types title and content
3. As user types, BibleToolkitBloc detects verses every 500ms
4. User clicks Save button
5. Validation: Check if title is not empty
6. Create Note entity with UUID and timestamps
7. NotesBloc.add(AddNoteEvent(note))
8. AddNote use case executes
9. NoteRepositoryImpl.addNote() called
10. NoteLocalDataSource.insertNote() called
11. SQLite INSERT operation
12. Success state emitted
13. SnackBar shows "Note saved successfully"
14. Navigate back to list
15. NotesListPage reloads to show new note
```

### Previewing a Bible Verse

```
1. User types "Check John 3:16 for context"
2. After 500ms pause, BibleToolkitBloc detects "John 3:16"
3. VersePreviewButton appears at bottom-right
4. User taps preview button
5. VersePreviewDialog opens
6. VerseFetchBloc.add(FetchVerseEvent("John 3:16"))
7. GetVerse use case executes
8. BibleRepositoryImpl.getVerse() called
9. BibleApiService makes HTTP GET to bible-api.com/John%203:16
10. Response parsed into BibleVerseModel
11. VerseFetchLoaded state emitted
12. Dialog displays verse text
13. User can copy or insert verse
```

---

## Testing Strategy

### Unit Tests

**Data Layer:**

- `bible_api_service_test.dart`: Tests API calls, error handling, timeouts
- `bible_reference_parser_test.dart`: Tests regex patterns, edge cases

**Domain Layer:**

- Use case tests (individual business logic)
- Entity tests (value objects)

**Presentation Layer:**

- BLoC tests (event → state transitions)
- Widget tests (UI components)

### Test Coverage Areas

```dart
✓ Successful API responses
✓ Network error handling (no internet)
✓ 404 Not Found errors
✓ Server errors (500+)
✓ Timeout scenarios
✓ Verse detection accuracy
✓ False positive prevention (e.g., "Mark said hello")
✓ Multiple format support (colon, vs, v)
✓ Database CRUD operations
✓ State transitions in BLoCs
```

---

## Performance Optimizations

1. **Debouncing**: Prevents excessive parsing during typing (500ms delay)
2. **Database Indexes**: Fast queries on createdAt and updatedAt columns
3. **Lazy Loading**: Dependencies loaded only when needed via GetIt
4. **Efficient Parsing**: Only analyzes current line, not entire document
5. **Connection Pooling**: Reuses HTTP client for multiple API requests
6. **Conflict Resolution**: SQLite uses `REPLACE` strategy for efficient updates

---

## Future Enhancement Opportunities

1. **Offline Verse Storage**: Cache fetched verses locally
2. **Export/Share Notes**: PDF or text export functionality
3. **Cloud Sync**: Backup notes to cloud storage
4. **Tags & Categories**: Organize notes by sermon series/topics
5. **Rich Text Formatting**: Bold, italic, highlights
6. **Audio Recording**: Record sermon audio attached to notes
7. **Verse Highlighting**: Highlight detected verses in content
8. **Multiple Bible Translations**: Support KJV, NIV, ESV, etc.
9. **Verse Collections**: Save favorite verses separately
10. **Handwriting Support**: Stylus/Apple Pencil input

---

## Key Design Decisions

### Why Clean Architecture?

- **Testability**: Mock dependencies easily for unit tests
- **Independence**: UI can change without affecting business logic
- **Flexibility**: Easy to swap data sources (e.g., Firebase instead of SQLite)

### Why BLoC Pattern?

- **Predictable State**: All state changes are traceable
- **Separation**: UI completely separated from business logic
- **Testable**: Easy to test state transitions
- **Reactive**: Automatically updates UI on state changes

### Why Local-First Storage?

- **Offline Access**: Works without internet connection
- **Privacy**: Notes stay on device
- **Performance**: Fast local database queries
- **Reliability**: No dependency on external services for core features

### Why Debouncing?

- **Performance**: Reduces unnecessary parsing operations
- **User Experience**: Doesn't interrupt typing flow
- **Battery Life**: Fewer CPU cycles during intensive typing

---

## Technical Dependencies

```yaml
# State Management
flutter_bloc: ^8.1.3 # BLoC pattern implementation
equatable: ^2.0.5 # Value comparison for states

# Local Storage
sqflite: ^2.3.0 # SQLite database
path: ^1.8.3 # File path utilities

# Networking
http: ^1.1.0 # HTTP client for API calls

# Reactive Programming
rxdart: ^0.27.7 # Debouncing and streams

# Dependency Injection
get_it: ^7.6.4 # Service locator

# Utilities
uuid: ^4.2.1 # Unique ID generation
```

---

## Conclusion

SermonNotes demonstrates a well-architected Flutter application with:

- ✅ Clean separation of concerns
- ✅ Robust error handling
- ✅ Intelligent feature implementation (verse detection)
- ✅ Offline-first architecture
- ✅ Comprehensive testing approach
- ✅ Scalable codebase structure

The app successfully balances technical excellence with user-focused features, making it a practical tool for sermon note-taking while showcasing modern Flutter development best practices.
