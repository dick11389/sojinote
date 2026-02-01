# SermonNotes Advanced Features - Complete Implementation Guide

## Feature 1: Offline Verse Storage (Caching)

**Purpose**: Cache fetched verses locally for offline access with automatic expiration

### Files Created:

- `lib/domain/entities/cached_verse.dart`
- `lib/data/models/cached_verse_model.dart`
- `lib/data/datasources/bible_local_datasource.dart`
- `lib/domain/usecases/get_cached_verse.dart`
- `lib/domain/usecases/clear_verse_cache.dart`

### Database Schema:

```sql
CREATE TABLE verses_cache (
  reference TEXT PRIMARY KEY,
  text TEXT NOT NULL,
  book TEXT NOT NULL,
  chapter INTEGER NOT NULL,
  verse INTEGER NOT NULL,
  cachedAt TEXT NOT NULL,
  expiresAt TEXT NOT NULL
);
```

### Implementation:

1. Add `CachedVerse` entity with expiration logic
2. Implement `VerseCacheDatasource` for SQLite operations
3. Create `CacheManagerWidget` for UI cache management
4. Auto-expire verses after 7 days

### Git Commit:

```
feat(cache): Add offline verse caching with 7-day expiration

- Implement CachedVerse entity and model
- Add verse cache database table with indexes
- Create VerseCacheDatasource for local persistence
- Add GetCachedVerse and ClearVerseCache use cases
- Implement cache manager widget
- Configure automatic cache expiration
```

---

## Feature 2: Export/Share Notes

**Purpose**: Export notes in multiple formats (Text, PDF, Markdown) and share via native sharing

### Files Created:

- `lib/domain/entities/exported_note.dart`
- `lib/domain/entities/export_format.dart`
- `lib/data/models/export_model.dart`
- `lib/domain/usecases/export_note.dart`
- `lib/presentation/bloc/export/export_event.dart`
- `lib/presentation/bloc/export/export_state.dart`
- `lib/presentation/bloc/export/export_bloc.dart`
- `lib/presentation/widgets/export_options_dialog.dart`

### Supported Formats:

- **Text**: ASCII formatted with metadata
- **PDF**: Professional document with cover page
- **Markdown**: GitHub-ready format

### Implementation:

```dart
// Export options
enum ExportFormat { text, pdf, markdown }

// Use in UI
showDialog(
  context: context,
  builder: (context) => ExportOptionsDialog(noteId: note.id),
);
```

### Git Commit:

```
feat(export): Add note export and sharing functionality

- Create ExportedNote entity with format options
- Implement PDF export service using pdf package
- Add text and markdown format exporters
- Create ExportBloc for export state management
- Add ExportOptionsDialog for format selection
- Integrate share_plus for native sharing
- Add path_provider for file system access
```

---

## Feature 3: Cloud Sync

**Purpose**: Synchronize notes to cloud with conflict resolution and auto-sync

### Files Created:

- `lib/domain/entities/cloud_backup.dart`
- `lib/data/models/cloud_backup_model.dart`
- `lib/data/datasources/cloud_datasource.dart`
- `lib/domain/repositories/cloud_repository.dart`
- `lib/data/repositories/cloud_repository_impl.dart`
- `lib/domain/usecases/cloud_sync_usecases.dart`
- `lib/presentation/bloc/sync/cloud_sync_bloc.dart`

### Database Schema:

```sql
CREATE TABLE cloud_backups (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL,
  deviceId TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  lastSyncAt TEXT NOT NULL,
  noteCount INTEGER NOT NULL,
  backupUrl TEXT NOT NULL,
  isComplete INTEGER NOT NULL,
  status TEXT NOT NULL,
  errorMessage TEXT
);

CREATE TABLE sync_queue (
  id TEXT PRIMARY KEY,
  operation TEXT NOT NULL,
  entityType TEXT NOT NULL,
  entityId TEXT NOT NULL,
  payload TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  status TEXT NOT NULL,
  retryCount INTEGER NOT NULL
);
```

### Key Features:

- 5-minute auto-sync interval (configurable)
- Conflict resolution with last-write-wins strategy
- Retry logic with exponential backoff
- Sync status tracking

### Git Commit:

```
feat(cloud): Add Firebase cloud sync with auto-sync

- Implement CloudBackup entity for backup tracking
- Add cloud_backups and sync_queue database tables
- Create CloudDatasource with remote/local implementations
- Implement CloudRepository with sync logic
- Add SyncNotesToCloud and EnableAutoSync use cases
- Create CloudSyncBloc for state management
- Implement 5-minute auto-sync with conflict resolution
```

---

## Feature 4: Tags & Categories

**Purpose**: Organize notes with flexible tagging and category system

### Files Created:

- `lib/domain/entities/note_tag.dart` (updated)
- `lib/data/models/note_tag_model.dart`
- `lib/data/datasources/tag_category_datasource.dart`
- `lib/domain/repositories/tag_category_repository.dart`
- `lib/data/repositories/tag_category_repository_impl.dart`
- `lib/domain/usecases/tag_category_usecases.dart`
- `lib/presentation/bloc/tags/tags_bloc.dart`
- `lib/presentation/widgets/tag_selector_widget.dart`
- `lib/presentation/widgets/category_selector_widget.dart`

### Database Schema:

```sql
CREATE TABLE note_tags (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  color TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  usageCount INTEGER NOT NULL
);

CREATE TABLE note_categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  icon TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  noteCount INTEGER NOT NULL
);

CREATE TABLE note_tags_junction (
  noteId TEXT NOT NULL,
  tagId TEXT NOT NULL,
  PRIMARY KEY (noteId, tagId)
);

ALTER TABLE notes ADD COLUMN categoryId TEXT;
```

### Features:

- Create/delete tags with custom colors
- Assign categories to notes
- Search notes by tags
- Tag usage statistics

### Git Commit:

```
feat(tags): Add tagging and categorization system

- Create NoteTag and NoteCategory entities
- Add tag and category database tables with indexes
- Create TagCategoryDatasource for persistence
- Implement TagCategoryRepository
- Add CreateTag, CreateCategory, SearchNotesByTag use cases
- Create TagsBloc for tag management
- Add tag and category selector widgets
- Implement search by tags functionality
```

---

## Feature 5: Rich Text Formatting

**Purpose**: Support bold, italic, underline, colors, and highlighting in notes

### Files Created:

- `lib/presentation/widgets/rich_text_editor.dart`
- `lib/core/utils/rich_text_formatter.dart`
- `lib/domain/entities/text_style.dart`
- `lib/presentation/bloc/text_formatting/formatting_bloc.dart`
- `lib/presentation/widgets/text_formatting_toolbar.dart`

### Database Schema Extension:

```sql
ALTER TABLE notes ADD COLUMN richTextHtml TEXT;
ALTER TABLE notes ADD COLUMN formattingVersion TEXT DEFAULT '1';

CREATE TABLE text_formatting_history (
  id TEXT PRIMARY KEY,
  noteId TEXT NOT NULL,
  format TEXT NOT NULL,
  content TEXT NOT NULL,
  timestamp TEXT NOT NULL
);
```

### Supported Styles:

- Bold, Italic, Underline
- Font colors and highlighting
- Custom font sizes
- Undo/Redo functionality

### Git Commit:

```
feat(rich-text): Add rich text formatting support

- Create RichTextEditor widget with formatting toolbar
- Add bold, italic, underline, color, highlight support
- Implement HTML serialization for rich text
- Add text formatting history for undo/redo
- Create FormattingBloc for state management
- Store formatted text in notes table
- Support export with formatting preserved
```

---

## Feature 6: Audio Recording

**Purpose**: Record, play, and transcribe audio notes with verse references

### Files Created:

- `lib/domain/entities/audio_recording.dart` (created)
- `lib/data/models/audio_recording_model.dart`
- `lib/data/datasources/audio_datasource.dart`
- `lib/domain/repositories/audio_repository.dart`
- `lib/data/repositories/audio_repository_impl.dart`
- `lib/domain/usecases/audio_usecases.dart`
- `lib/presentation/bloc/audio/audio_bloc.dart`
- `lib/presentation/widgets/audio_recorder_widget.dart`
- `lib/presentation/widgets/audio_player_widget.dart`

### Database Schema:

```sql
CREATE TABLE audio_recordings (
  id TEXT PRIMARY KEY,
  noteId TEXT NOT NULL,
  filePath TEXT NOT NULL UNIQUE,
  durationMs INTEGER NOT NULL,
  recordedAt TEXT NOT NULL,
  title TEXT,
  transcription TEXT,
  fileSize REAL NOT NULL,
  isProcessing INTEGER NOT NULL,
  processingStatus TEXT
);
```

### Features:

- Record audio with permissions handling
- Play recordings with controls
- Automatic transcription (placeholder)
- Audio file size tracking

### Dependencies:

```yaml
record: ^5.0.0
just_audio: ^0.9.0
```

### Git Commit:

```
feat(audio): Add audio recording and playback

- Create AudioRecording entity and model
- Implement AudioDatasource for persistence
- Add record and just_audio packages
- Create AudioBloc for recording state
- Implement AudioRecorderWidget with controls
- Add AudioPlayerWidget with playback controls
- Support audio transcription integration
- Store recordings with notes in database
```

---

## Feature 7: Verse Highlighting

**Purpose**: Highlight important verses with colors and personal notes

### Files Created:

- `lib/domain/entities/highlighted_verse.dart` (created)
- `lib/data/models/highlighted_verse_model.dart`
- `lib/data/datasources/verse_datasource.dart`
- `lib/domain/repositories/verse_repository.dart`
- `lib/data/repositories/verse_repository_impl.dart`
- `lib/domain/usecases/verse_feature_usecases.dart`
- `lib/presentation/bloc/verse/verse_bloc.dart`
- `lib/presentation/widgets/verse_highlighter_widget.dart`

### Database Schema:

```sql
CREATE TABLE highlighted_verses (
  id TEXT PRIMARY KEY,
  noteId TEXT NOT NULL,
  reference TEXT NOT NULL,
  text TEXT NOT NULL,
  highlightColor TEXT NOT NULL,
  highlightNotes TEXT,
  highlightedAt TEXT NOT NULL,
  isStarred INTEGER NOT NULL
);
```

### Features:

- Highlight verses with custom colors
- Add personal notes to highlights
- Star important highlights
- Filter by highlight color

### Git Commit:

```
feat(highlight): Add verse highlighting with colors

- Create HighlightedVerse entity and model
- Add highlighted_verses database table
- Implement VerseDatasource for persistence
- Create VerseBloc for highlight management
- Add VerseHighlighterWidget for UI
- Support highlight color selection
- Add notes to individual highlights
- Implement star/favorite functionality
```

---

## Feature 8: Multiple Bible Translations

**Purpose**: Support multiple Bible translations (KJV, NIV, ESV, NASB) with parallel view

### Files Created:

- `lib/domain/entities/bible_translation.dart` (created)
- `lib/data/models/bible_translation_model.dart`
- `lib/data/datasources/translation_datasource.dart`
- `lib/domain/repositories/translation_repository.dart`
- `lib/data/repositories/translation_repository_impl.dart`
- `lib/domain/usecases/translation_usecases.dart`
- `lib/presentation/bloc/translation/translation_bloc.dart`
- `lib/presentation/widgets/translation_selector_widget.dart`
- `lib/presentation/widgets/parallel_verse_viewer.dart`

### Database Schema:

```sql
CREATE TABLE bible_translations (
  id TEXT PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  abbreviation TEXT NOT NULL UNIQUE,
  language TEXT NOT NULL,
  description TEXT,
  isDefault INTEGER NOT NULL,
  isDownloaded INTEGER NOT NULL,
  downloadedAt TEXT,
  apiEndpoint TEXT
);

-- Default translations
INSERT INTO bible_translations VALUES
  ('1', 'KJV', 'King James Version', 'KJV', 'English', ...),
  ('2', 'NIV', 'New International Version', 'NIV', 'English', ...),
  ('3', 'ESV', 'English Standard Version', 'ESV', 'English', ...),
  ('4', 'NASB', 'New American Standard Bible', 'NASB', 'English', ...);
```

### Features:

- Switch between 4+ translations
- Download translations for offline use
- Parallel view with multiple translations
- Set default translation

### Git Commit:

```
feat(translations): Add multiple Bible translation support

- Create BibleTranslation entity with download tracking
- Add bible_translations database table with defaults
- Implement TranslationDatasource for persistence
- Create TranslationRepository for API integration
- Add GetAvailableTranslations use case
- Create TranslationBloc for selection state
- Implement TranslationSelector widget
- Add ParallelVerseViewer for side-by-side comparison
- Support KJV, NIV, ESV, NASB translations
```

---

## Feature 9: Verse Collections

**Purpose**: Organize verses into thematic collections with sharing capability

### Files Created:

- `lib/domain/entities/verse_collection.dart` (created)
- `lib/data/models/verse_collection_model.dart`
- `lib/presentation/bloc/collection/collection_bloc.dart`
- `lib/presentation/widgets/collection_manager_widget.dart`
- `lib/presentation/widgets/add_to_collection_dialog.dart`

### Database Schema:

```sql
CREATE TABLE verse_collections (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  verseReferences TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  updatedAt TEXT,
  color TEXT,
  isPublic INTEGER NOT NULL,
  viewCount INTEGER NOT NULL
);
```

### Features:

- Create named verse collections
- Add/remove verses from collections
- Share collections via link
- Public/private visibility
- View count tracking

### Git Commit:

```
feat(collections): Add verse collection management

- Create VerseCollection entity and model
- Add verse_collections database table
- Implement collection creation and management
- Add verses to collections functionality
- Create collection sharing with public links
- Implement CollectionBloc for state
- Add CollectionManagerWidget UI
- Support public/private collection visibility
- Track collection view counts
```

---

## Feature 10: Handwriting Support

**Purpose**: Add drawing canvas for handwritten notes with gesture recognition

### Files Created:

- `lib/presentation/widgets/drawing_canvas_widget.dart`
- `lib/presentation/widgets/handwriting_recognizer_widget.dart`
- `lib/domain/entities/handwriting_sketch.dart`
- `lib/data/models/handwriting_model.dart`
- `lib/presentation/bloc/handwriting/handwriting_bloc.dart`

### Database Schema:

```sql
CREATE TABLE handwriting_sketches (
  id TEXT PRIMARY KEY,
  noteId TEXT NOT NULL,
  sketchData TEXT NOT NULL,
  thumbnailPath TEXT,
  createdAt TEXT NOT NULL,
  updatedAt TEXT,
  width REAL NOT NULL,
  height REAL NOT NULL,
  backgroundColor TEXT DEFAULT '#FFFFFF',
  strokeColor TEXT DEFAULT '#000000'
);

CREATE TABLE handwriting_recognition (
  id TEXT PRIMARY KEY,
  sketchId TEXT NOT NULL,
  recognizedText TEXT,
  confidence REAL NOT NULL,
  recognizedAt TEXT NOT NULL
);
```

### Features:

- Draw freehand on canvas
- Undo/Redo functionality
- Color and stroke width options
- Save sketches as images
- Optional gesture recognition

### Dependencies:

```yaml
perfect_freehand: ^1.0.0
```

### Git Commit:

```
feat(handwriting): Add handwriting and drawing support

- Create DrawingCanvasWidget for freehand drawing
- Implement stroke rendering with perfect_freehand
- Add color picker and stroke width controls
- Implement undo/redo for drawing operations
- Create sketch model and database schema
- Add HandwritingRecognizerWidget for OCR
- Implement sketch thumbnail generation
- Save sketches as images in notes
- Create HandwritingBloc for state management
```

---

## Updated pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  sqflite: ^2.3.0
  http: ^1.1.0
  get_it: ^7.6.4
  uuid: ^4.2.1
  rxdart: ^0.27.7
  equatable: ^2.0.5
  dartz: ^0.10.0

  # New Advanced Features
  pdf: ^3.10.0
  printing: ^5.10.0
  share_plus: ^7.2.0
  intl: ^0.19.0

  # Firebase for Cloud Sync
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0

  # Audio Recording
  record: ^5.0.0
  just_audio: ^0.9.0

  # Rich Text
  flutter_quill: ^8.6.0

  # Handwriting
  perfect_freehand: ^1.0.0
```

---

## Installation & Integration Steps

1. **Update pubspec.yaml** with all dependencies
2. **Run migration scripts** in sequence (V3-V10)
3. **Update DI Container** (injection_container.dart) with all repositories
4. **Create BLoCs** for each feature
5. **Add widgets** to relevant pages
6. **Configure Firebase** for cloud features
7. **Test each feature** independently

---

## Commit Summary

10 feature commits implementing:

- Offline caching
- Export/sharing
- Cloud sync
- Tags/categories
- Rich text formatting
- Audio recording
- Verse highlighting
- Multiple translations
- Collections
- Handwriting support

Total new code: ~3,500 lines across entities, models, datasources, repositories, use cases, and UI widgets.
