/// Database Migration Scripts for SermonNotes Advanced Features
/// Run these migrations in sequence to update your database schema

/// MIGRATION: V3_ADD_CLOUD_SYNC_TABLES
/// Adds cloud synchronization tracking tables
const String migrationV3AddCloudSync = '''
  -- Create cloud_backups table
  CREATE TABLE IF NOT EXISTS cloud_backups (
    id TEXT PRIMARY KEY,
    userId TEXT NOT NULL,
    deviceId TEXT NOT NULL,
    createdAt TEXT NOT NULL,
    lastSyncAt TEXT NOT NULL,
    noteCount INTEGER NOT NULL,
    backupUrl TEXT NOT NULL,
    isComplete INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'pending',
    errorMessage TEXT,
    UNIQUE(userId, deviceId)
  );
  
  -- Create sync_queue table for pending operations
  CREATE TABLE IF NOT EXISTS sync_queue (
    id TEXT PRIMARY KEY,
    operation TEXT NOT NULL,
    entityType TEXT NOT NULL,
    entityId TEXT NOT NULL,
    payload TEXT NOT NULL,
    createdAt TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    retryCount INTEGER NOT NULL DEFAULT 0
  );
  
  -- Create indexes for performance
  CREATE INDEX IF NOT EXISTS idx_cloud_backups_userId ON cloud_backups(userId);
  CREATE INDEX IF NOT EXISTS idx_cloud_backups_status ON cloud_backups(status);
  CREATE INDEX IF NOT EXISTS idx_sync_queue_status ON sync_queue(status);
  CREATE INDEX IF NOT EXISTS idx_sync_queue_createdAt ON sync_queue(createdAt);
''';

/// MIGRATION: V4_ADD_TAGS_CATEGORIES
/// Adds tag and category system for note organization
const String migrationV4AddTagsCategories = '''
  -- Create note_tags table
  CREATE TABLE IF NOT EXISTS note_tags (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    color TEXT NOT NULL,
    createdAt TEXT NOT NULL,
    usageCount INTEGER NOT NULL DEFAULT 0
  );
  
  -- Create note_categories table
  CREATE TABLE IF NOT EXISTS note_categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    icon TEXT NOT NULL,
    createdAt TEXT NOT NULL,
    noteCount INTEGER NOT NULL DEFAULT 0
  );
  
  -- Create junction table for notes and tags (many-to-many)
  CREATE TABLE IF NOT EXISTS note_tags_junction (
    noteId TEXT NOT NULL,
    tagId TEXT NOT NULL,
    PRIMARY KEY (noteId, tagId),
    FOREIGN KEY (noteId) REFERENCES notes(id) ON DELETE CASCADE,
    FOREIGN KEY (tagId) REFERENCES note_tags(id) ON DELETE CASCADE
  );
  
  -- Add categoryId to notes table (if not exists)
  ALTER TABLE notes ADD COLUMN categoryId TEXT REFERENCES note_categories(id);
  
  -- Create indexes
  CREATE INDEX IF NOT EXISTS idx_note_tags_name ON note_tags(name);
  CREATE INDEX IF NOT EXISTS idx_note_categories_name ON note_categories(name);
  CREATE INDEX IF NOT EXISTS idx_note_tags_junction_tagId ON note_tags_junction(tagId);
''';

/// MIGRATION: V5_ADD_HIGHLIGHTED_VERSES
/// Adds verse highlighting and annotation system
const String migrationV5AddHighlightedVerses = '''
  -- Create highlighted_verses table
  CREATE TABLE IF NOT EXISTS highlighted_verses (
    id TEXT PRIMARY KEY,
    noteId TEXT NOT NULL,
    reference TEXT NOT NULL,
    text TEXT NOT NULL,
    highlightColor TEXT NOT NULL,
    highlightNotes TEXT,
    highlightedAt TEXT NOT NULL,
    isStarred INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (noteId) REFERENCES notes(id) ON DELETE CASCADE
  );
  
  -- Create indexes
  CREATE INDEX IF NOT EXISTS idx_highlighted_verses_noteId ON highlighted_verses(noteId);
  CREATE INDEX IF NOT EXISTS idx_highlighted_verses_reference ON highlighted_verses(reference);
  CREATE INDEX IF NOT EXISTS idx_highlighted_verses_isStarred ON highlighted_verses(isStarred);
  CREATE INDEX IF NOT EXISTS idx_highlighted_verses_highlightedAt ON highlighted_verses(highlightedAt);
''';

/// MIGRATION: V6_ADD_BIBLE_TRANSLATIONS
/// Adds support for multiple Bible translations
const String migrationV6AddBibleTranslations = '''
  -- Create bible_translations table
  CREATE TABLE IF NOT EXISTS bible_translations (
    id TEXT PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    abbreviation TEXT NOT NULL UNIQUE,
    language TEXT NOT NULL,
    description TEXT,
    isDefault INTEGER NOT NULL DEFAULT 0,
    isDownloaded INTEGER NOT NULL DEFAULT 0,
    downloadedAt TEXT,
    apiEndpoint TEXT
  );
  
  -- Create default translations
  INSERT OR IGNORE INTO bible_translations VALUES
    ('1', 'KJV', 'King James Version', 'KJV', 'English', 'Classic translation', 1, 1, datetime('now'), 'https://api.bible.com/v1/verses'),
    ('2', 'NIV', 'New International Version', 'NIV', 'English', 'Modern translation', 0, 0, NULL, 'https://api.bible.com/v1/verses'),
    ('3', 'ESV', 'English Standard Version', 'ESV', 'English', 'Formal translation', 0, 0, NULL, 'https://api.bible.com/v1/verses'),
    ('4', 'NASB', 'New American Standard Bible', 'NASB', 'English', 'Literal translation', 0, 0, NULL, 'https://api.bible.com/v1/verses');
  
  -- Create indexes
  CREATE INDEX IF NOT EXISTS idx_bible_translations_code ON bible_translations(code);
  CREATE INDEX IF NOT EXISTS idx_bible_translations_isDefault ON bible_translations(isDefault);
  CREATE INDEX IF NOT EXISTS idx_bible_translations_isDownloaded ON bible_translations(isDownloaded);
''';

/// MIGRATION: V7_ADD_VERSE_COLLECTIONS
/// Adds ability to organize verses into collections
const String migrationV7AddVerseCollections = '''
  -- Create verse_collections table
  CREATE TABLE IF NOT EXISTS verse_collections (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    verseReferences TEXT NOT NULL,
    createdAt TEXT NOT NULL,
    updatedAt TEXT,
    color TEXT,
    isPublic INTEGER NOT NULL DEFAULT 0,
    viewCount INTEGER NOT NULL DEFAULT 0
  );
  
  -- Create indexes
  CREATE INDEX IF NOT EXISTS idx_verse_collections_name ON verse_collections(name);
  CREATE INDEX IF NOT EXISTS idx_verse_collections_isPublic ON verse_collections(isPublic);
  CREATE INDEX IF NOT EXISTS idx_verse_collections_createdAt ON verse_collections(createdAt);
''';

/// MIGRATION: V8_ADD_AUDIO_RECORDINGS
/// Adds audio recording and transcription support
const String migrationV8AddAudioRecordings = '''
  -- Create audio_recordings table
  CREATE TABLE IF NOT EXISTS audio_recordings (
    id TEXT PRIMARY KEY,
    noteId TEXT NOT NULL,
    filePath TEXT NOT NULL UNIQUE,
    durationMs INTEGER NOT NULL,
    recordedAt TEXT NOT NULL,
    title TEXT,
    transcription TEXT,
    fileSize REAL NOT NULL,
    isProcessing INTEGER NOT NULL DEFAULT 0,
    processingStatus TEXT,
    FOREIGN KEY (noteId) REFERENCES notes(id) ON DELETE CASCADE
  );
  
  -- Create indexes
  CREATE INDEX IF NOT EXISTS idx_audio_recordings_noteId ON audio_recordings(noteId);
  CREATE INDEX IF NOT EXISTS idx_audio_recordings_recordedAt ON audio_recordings(recordedAt);
  CREATE INDEX IF NOT EXISTS idx_audio_recordings_isProcessing ON audio_recordings(isProcessing);
''';

/// MIGRATION: V9_ADD_RICH_TEXT_SUPPORT
/// Extends notes table to support rich text formatting
const String migrationV9AddRichTextSupport = '''
  -- Add rich text columns to notes table
  ALTER TABLE notes ADD COLUMN richTextHtml TEXT;
  ALTER TABLE notes ADD COLUMN formattingVersion TEXT DEFAULT '1';
  
  -- Create text_formatting_history table for undo/redo
  CREATE TABLE IF NOT EXISTS text_formatting_history (
    id TEXT PRIMARY KEY,
    noteId TEXT NOT NULL,
    format TEXT NOT NULL,
    content TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    FOREIGN KEY (noteId) REFERENCES notes(id) ON DELETE CASCADE
  );
  
  -- Create indexes
  CREATE INDEX IF NOT EXISTS idx_text_formatting_history_noteId ON text_formatting_history(noteId);
  CREATE INDEX IF NOT EXISTS idx_text_formatting_history_timestamp ON text_formatting_history(timestamp);
''';

/// MIGRATION: V10_ADD_HANDWRITING_SUPPORT
/// Adds handwriting canvas and gesture recognition
const String migrationV10AddHandwritingSupport = '''
  -- Create handwriting_sketches table
  CREATE TABLE IF NOT EXISTS handwriting_sketches (
    id TEXT PRIMARY KEY,
    noteId TEXT NOT NULL,
    sketchData TEXT NOT NULL,
    thumbnailPath TEXT,
    createdAt TEXT NOT NULL,
    updatedAt TEXT,
    width REAL NOT NULL DEFAULT 0.0,
    height REAL NOT NULL DEFAULT 0.0,
    backgroundColor TEXT DEFAULT '#FFFFFF',
    strokeColor TEXT DEFAULT '#000000',
    FOREIGN KEY (noteId) REFERENCES notes(id) ON DELETE CASCADE
  );
  
  -- Create handwriting_recognition table for OCR results
  CREATE TABLE IF NOT EXISTS handwriting_recognition (
    id TEXT PRIMARY KEY,
    sketchId TEXT NOT NULL,
    recognizedText TEXT,
    confidence REAL NOT NULL,
    recognizedAt TEXT NOT NULL,
    FOREIGN KEY (sketchId) REFERENCES handwriting_sketches(id) ON DELETE CASCADE
  );
  
  -- Create indexes
  CREATE INDEX IF NOT EXISTS idx_handwriting_sketches_noteId ON handwriting_sketches(noteId);
  CREATE INDEX IF NOT EXISTS idx_handwriting_recognition_sketchId ON handwriting_recognition(sketchId);
  CREATE INDEX IF NOT EXISTS idx_handwriting_recognition_confidence ON handwriting_recognition(confidence);
''';

/// Migration execution function
const List<String> allMigrations = [
  migrationV3AddCloudSync,
  migrationV4AddTagsCategories,
  migrationV5AddHighlightedVerses,
  migrationV6AddBibleTranslations,
  migrationV7AddVerseCollections,
  migrationV8AddAudioRecordings,
  migrationV9AddRichTextSupport,
  migrationV10AddHandwritingSupport,
];
