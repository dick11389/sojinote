/// Database Migration Execution and Rollback Guide
///
/// This file provides migration execution scripts, rollback procedures,
/// and verification queries for the SermonNotes advanced features database updates.

/// MIGRATION EXECUTION GUIDE
/// ===========================

/// Step 1: Execute migrations in order
const String executeMigrationsSQL = '''
-- Start transaction
BEGIN TRANSACTION;

-- V3: Cloud Sync Tables
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

CREATE INDEX IF NOT EXISTS idx_cloud_backups_userId ON cloud_backups(userId);
CREATE INDEX IF NOT EXISTS idx_cloud_backups_status ON cloud_backups(status);
CREATE INDEX IF NOT EXISTS idx_sync_queue_status ON sync_queue(status);
CREATE INDEX IF NOT EXISTS idx_sync_queue_createdAt ON sync_queue(createdAt);

-- V4: Tags & Categories
CREATE TABLE IF NOT EXISTS note_tags (
id TEXT PRIMARY KEY,
name TEXT NOT NULL UNIQUE,
description TEXT,
color TEXT NOT NULL,
createdAt TEXT NOT NULL,
usageCount INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS note_categories (
id TEXT PRIMARY KEY,
name TEXT NOT NULL UNIQUE,
description TEXT,
icon TEXT NOT NULL,
createdAt TEXT NOT NULL,
noteCount INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS note_tags_junction (
noteId TEXT NOT NULL,
tagId TEXT NOT NULL,
PRIMARY KEY (noteId, tagId),
FOREIGN KEY (noteId) REFERENCES notes(id) ON DELETE CASCADE,
FOREIGN KEY (tagId) REFERENCES note_tags(id) ON DELETE CASCADE
);

ALTER TABLE notes ADD COLUMN categoryId TEXT REFERENCES note_categories(id);

CREATE INDEX IF NOT EXISTS idx_note_tags_name ON note_tags(name);
CREATE INDEX IF NOT EXISTS idx_note_categories_name ON note_categories(name);
CREATE INDEX IF NOT EXISTS idx_note_tags_junction_tagId ON note_tags_junction(tagId);

-- V5: Highlighted Verses
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

CREATE INDEX IF NOT EXISTS idx_highlighted_verses_noteId ON highlighted_verses(noteId);
CREATE INDEX IF NOT EXISTS idx_highlighted_verses_reference ON highlighted_verses(reference);
CREATE INDEX IF NOT EXISTS idx_highlighted_verses_isStarred ON highlighted_verses(isStarred);
CREATE INDEX IF NOT EXISTS idx_highlighted_verses_highlightedAt ON highlighted_verses(highlightedAt);

-- V6: Bible Translations
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

INSERT OR IGNORE INTO bible_translations VALUES
('1', 'KJV', 'King James Version', 'KJV', 'English', 'Classic translation', 1, 1, datetime('now'), 'https://api.bible.com/v1/verses'),
('2', 'NIV', 'New International Version', 'NIV', 'English', 'Modern translation', 0, 0, NULL, 'https://api.bible.com/v1/verses'),
('3', 'ESV', 'English Standard Version', 'ESV', 'English', 'Formal translation', 0, 0, NULL, 'https://api.bible.com/v1/verses'),
('4', 'NASB', 'New American Standard Bible', 'NASB', 'English', 'Literal translation', 0, 0, NULL, 'https://api.bible.com/v1/verses');

CREATE INDEX IF NOT EXISTS idx_bible_translations_code ON bible_translations(code);
CREATE INDEX IF NOT EXISTS idx_bible_translations_isDefault ON bible_translations(isDefault);
CREATE INDEX IF NOT EXISTS idx_bible_translations_isDownloaded ON bible_translations(isDownloaded);

-- V7: Verse Collections
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

CREATE INDEX IF NOT EXISTS idx_verse_collections_name ON verse_collections(name);
CREATE INDEX IF NOT EXISTS idx_verse_collections_isPublic ON verse_collections(isPublic);
CREATE INDEX IF NOT EXISTS idx_verse_collections_createdAt ON verse_collections(createdAt);

-- V8: Audio Recordings
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

CREATE INDEX IF NOT EXISTS idx_audio_recordings_noteId ON audio_recordings(noteId);
CREATE INDEX IF NOT EXISTS idx_audio_recordings_recordedAt ON audio_recordings(recordedAt);
CREATE INDEX IF NOT EXISTS idx_audio_recordings_isProcessing ON audio_recordings(isProcessing);

-- V9: Rich Text Support
ALTER TABLE notes ADD COLUMN richTextHtml TEXT;
ALTER TABLE notes ADD COLUMN formattingVersion TEXT DEFAULT '1';

CREATE TABLE IF NOT EXISTS text_formatting_history (
id TEXT PRIMARY KEY,
noteId TEXT NOT NULL,
format TEXT NOT NULL,
content TEXT NOT NULL,
timestamp TEXT NOT NULL,
FOREIGN KEY (noteId) REFERENCES notes(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_text_formatting_history_noteId ON text_formatting_history(noteId);
CREATE INDEX IF NOT EXISTS idx_text_formatting_history_timestamp ON text_formatting_history(timestamp);

-- V10: Handwriting Support
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

CREATE TABLE IF NOT EXISTS handwriting_recognition (
id TEXT PRIMARY KEY,
sketchId TEXT NOT NULL,
recognizedText TEXT,
confidence REAL NOT NULL,
recognizedAt TEXT NOT NULL,
FOREIGN KEY (sketchId) REFERENCES handwriting_sketches(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_handwriting_sketches_noteId ON handwriting_sketches(noteId);
CREATE INDEX IF NOT EXISTS idx_handwriting_recognition_sketchId ON handwriting_recognition(sketchId);
CREATE INDEX IF NOT EXISTS idx_handwriting_recognition_confidence ON handwriting_recognition(confidence);

-- Commit transaction
COMMIT;
''';

/// ROLLBACK PROCEDURES
/// ===================

const String rollbackV10Handwriting = '''
DROP TABLE IF EXISTS handwriting_recognition;
DROP TABLE IF EXISTS handwriting_sketches;
''';

const String rollbackV9RichText = '''
DROP TABLE IF EXISTS text_formatting_history;
ALTER TABLE notes DROP COLUMN richTextHtml;
ALTER TABLE notes DROP COLUMN formattingVersion;
''';

const String rollbackV8Audio = '''
DROP TABLE IF EXISTS audio_recordings;
''';

const String rollbackV7Collections = '''
DROP TABLE IF EXISTS verse_collections;
''';

const String rollbackV6Translations = '''
DELETE FROM bible_translations WHERE code IN ('KJV', 'NIV', 'ESV', 'NASB');
DROP TABLE IF EXISTS bible_translations;
''';

const String rollbackV5HighlightedVerses = '''
DROP TABLE IF EXISTS highlighted_verses;
''';

const String rollbackV4TagsCategories = '''
DROP TABLE IF EXISTS note_tags_junction;
DROP TABLE IF EXISTS note_categories;
DROP TABLE IF EXISTS note_tags;
ALTER TABLE notes DROP COLUMN categoryId;
''';

const String rollbackV3CloudSync = '''
DROP TABLE IF EXISTS sync_queue;
DROP TABLE IF EXISTS cloud_backups;
''';

/// VERIFICATION QUERIES
/// ====================

const String verifyMigrations = '''
-- Check all tables created
SELECT name FROM sqlite_master WHERE type='table' AND name LIKE '%backup%' OR name LIKE '%tag%' OR name LIKE '%highlight%' OR name LIKE '%translation%' OR name LIKE '%collection%' OR name LIKE '%audio%' OR name LIKE '%formatting%' OR name LIKE '%handwriting%';

-- Verify indexes
SELECT name FROM sqlite_master WHERE type='index' ORDER BY name;

-- Count records in new tables
SELECT 'cloud_backups' as table_name, COUNT(_) as count FROM cloud_backups
UNION ALL
SELECT 'note_tags', COUNT(_) FROM note_tags
UNION ALL
SELECT 'note_categories', COUNT(_) FROM note_categories
UNION ALL
SELECT 'highlighted_verses', COUNT(_) FROM highlighted_verses
UNION ALL
SELECT 'bible_translations', COUNT(_) FROM bible_translations
UNION ALL
SELECT 'verse_collections', COUNT(_) FROM verse_collections
UNION ALL
SELECT 'audio_recordings', COUNT(_) FROM audio_recordings
UNION ALL
SELECT 'handwriting_sketches', COUNT(_) FROM handwriting_sketches;

-- Check default bible translations
SELECT id, code, name, isDefault FROM bible_translations;

-- Verify note columns extended
PRAGMA table_info(notes);

-- Check for any migration errors
SELECT 'Migration Verification Complete' as status;
''';

/// DATABASE INTEGRITY CHECKS
/// =========================

const String integrityChecks = '''
-- Foreign key constraint validation
PRAGMA foreign_keys = ON;

-- Check for orphaned records
SELECT 'Orphaned highlighted_verses' as check_name, COUNT(_) as count
FROM highlighted_verses hv
WHERE NOT EXISTS (SELECT 1 FROM notes n WHERE n.id = hv.noteId)
UNION ALL
SELECT 'Orphaned audio_recordings', COUNT(_)
FROM audio_recordings ar
WHERE NOT EXISTS (SELECT 1 FROM notes n WHERE n.id = ar.noteId)
UNION ALL
SELECT 'Orphaned handwriting_sketches', COUNT(_)
FROM handwriting_sketches hs
WHERE NOT EXISTS (SELECT 1 FROM notes n WHERE n.id = hs.noteId)
UNION ALL
SELECT 'Orphaned handwriting_recognition', COUNT(_)
FROM handwriting_recognition hr
WHERE NOT EXISTS (SELECT 1 FROM handwriting_sketches hs WHERE hs.id = hr.sketchId)
UNION ALL
SELECT 'Invalid category references', COUNT(\*)
FROM notes n
WHERE n.categoryId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM note_categories nc WHERE nc.id = n.categoryId);

-- Check database size
SELECT page_count \* page_size as size_bytes FROM pragma_page_count(), pragma_page_size();

-- VACUUM for optimization
VACUUM;

-- Final integrity check
PRAGMA integrity_check;
''';

/// BACKUP PROCEDURES
/// =================

const String backupBeforeMigration = '''
-- Create backup database
ATTACH DATABASE 'backup\_$(timestamp).db' AS backup;

-- Copy all tables
CREATE TABLE backup.notes AS SELECT _ FROM main.notes;
CREATE TABLE backup.bible_verses AS SELECT _ FROM main.bible_verses;
CREATE TABLE backup.cached_verses AS SELECT \* FROM main.cached_verses;

-- Detach backup
DETACH DATABASE backup;
''';

/// PERFORMANCE ANALYSIS
/// ====================

const String analyzePerformance = '''
-- Check query plans
EXPLAIN QUERY PLAN
SELECT \* FROM highlighted_verses WHERE noteId = '123' ORDER BY highlightedAt DESC;

EXPLAIN QUERY PLAN
SELECT \* FROM note_tags_junction WHERE tagId = '456';

EXPLAIN QUERY PLAN
SELECT \* FROM audio_recordings WHERE isProcessing = 1;

-- Update statistics for query optimization
ANALYZE;

-- Show table statistics
SELECT name, (SELECT COUNT(\*) FROM 'main'.'table_name') as rows FROM sqlite_master WHERE type='table';
''';
