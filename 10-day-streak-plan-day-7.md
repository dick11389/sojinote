# 10-Day Flutter Streak Plan: Day 7

## 📅 Day 7: Delete Functionality & UI Polish

### 🎯 Learning Goals

- Implement swipe-to-delete with Dismissible widget
- Add confirmation dialogs for destructive actions
- Improve date formatting
- Polish the UI for professional appearance
- Learn gesture handling in Flutter

### 📝 What You'll Build

Complete the CRUD operations with delete functionality and make the app look polished and professional!

---

### Step 1: Update Notes List with Dismissible

**Modify**: `lib/presentation/pages/notes_list_page.dart`

Replace the `_buildNoteCard` method:

```dart
Widget _buildNoteCard(BuildContext context, Note note) {
  return Dismissible(
    key: Key(note.id),
    direction: DismissDirection.endToStart,
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.red[600],
      child: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
    ),
    confirmDismiss: (direction) async {
      return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Note'),
            content: const Text(
              'Are you sure you want to delete this note? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    },
    onDismissed: (direction) {
      context.read<NotesBloc>().add(DeleteNoteEvent(note.id));
    },
    child: Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          note.title.isNotEmpty ? note.title : 'Untitled',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              note.content.isEmpty ? 'No content' : note.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(note.updatedAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (_) => getIt<NotesBloc>(),
                child: SermonEditorScreen(note: note),
              ),
            ),
          );

          if (result == true && mounted) {
            context.read<NotesBloc>().add(const LoadNotes());
          }
        },
      ),
    ),
  );
}

String _formatDate(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime).inDays;

  if (difference == 0) {
    return 'Today at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  } else if (difference == 1) {
    return 'Yesterday';
  } else if (difference < 7) {
    return '$difference days ago';
  } else if (difference < 30) {
    return '${(difference / 7).floor()} weeks ago';
  } else if (difference < 365) {
    return '${(difference / 30).floor()} months ago';
  } else {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
```

**🎓 What You're Learning:**

- **Dismissible Widget**: Native swipe gestures
- **confirmDismiss**: Ask before deleting
- **AlertDialog**: Material confirmation dialogs
- **Key Property**: Required for Dismissible to track items
- **Direction**: Only swipe from right to left

---

### Step 2: Add Get Bible Entities (Preparation)

**File**: `lib/domain/entities/bible_reference.dart`

```dart
import 'package:equatable/equatable.dart';

class BibleReference extends Equatable {
  final String book;
  final int chapter;
  final int? verseStart;
  final int? verseEnd;

  const BibleReference({
    required this.book,
    required this.chapter,
    this.verseStart,
    this.verseEnd,
  });

  /// Format reference as "John 3:16" or "Romans 8:28-30"
  String get formatted {
    if (verseStart == null) {
      return '$book $chapter';
    }
    if (verseEnd == null) {
      return '$book $chapter:$verseStart';
    }
    return '$book $chapter:$verseStart-$verseEnd';
  }

  /// Whether this is a chapter-only reference (no verses)
  bool get isChapterOnly => verseStart == null;

  /// Whether this is a verse range (has start and end verse)
  bool get isVerseRange => verseStart != null && verseEnd != null;

  @override
  List<Object?> get props => [book, chapter, verseStart, verseEnd];
}
```

**File**: `lib/domain/entities/bible_verse.dart`

```dart
import 'package:equatable/equatable.dart';

class BibleVerse extends Equatable {
  final String reference;
  final String text;
  final String book;
  final int chapter;
  final int verse;

  const BibleVerse({
    required this.reference,
    required this.text,
    required this.book,
    required this.chapter,
    required this.verse,
  });

  @override
  List<Object?> get props => [reference, text, book, chapter, verse];
}
```

---

### Step 3: Polish the App Appearance

**Modify**: `lib/main.dart` - Enhance theme:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'core/di/injection_container.dart';
import 'presentation/bloc/notes/notes_bloc.dart';
import 'presentation/pages/notes_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          elevation: 4,
          highlightElevation: 8,
        ),
        cardTheme: CardTheme(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: BlocProvider(
        create: (_) => di.getIt<NotesBloc>(),
        child: const NotesListPage(),
      ),
    );
  }
}
```

---

### 📦 Commit Your Work

```bash
git add .
git commit -m "Day 7: Add delete functionality and UI polish

- Implemented swipe-to-delete with Dismissible widget
- Added confirmation dialog before deletion
- Created smart date formatting (Today, Yesterday, X days ago)
- Improved card design with better spacing/elevation
- Added confirmation for destructive actions
- Enhanced AppBar and FAB theming
- Added Bible entities for future integration

Learning: Dismissible widget provides native swipe gestures!"

git push origin main
```

---

### 📖 Blog Entry: Day 7

**Title**: "Polishing the App: Delete Gestures and Professional Design"

**What I Built Today:**
CRUD is now complete! Users can:

- ✅ Create notes
- ✅ Read notes
- ✅ Update notes
- ✅ Delete notes

Plus I added professional polish with swipe gestures and confirmations.

**What I Learned:**

1. **Dismissible Widget**:

   ```dart
   Dismissible(
     key: Key(note.id),
     direction: DismissDirection.endToStart,
     background: Container(color: red, child: deleteIcon),
     confirmDismiss: (direction) => showDialog(...),
     onDismissed: (direction) => deleteNote(),
     child: Card(...),
   )
   ```

   This provides the native iOS-style swipe-to-delete!

2. **Confirmation Dialogs**:

   ```dart
   showDialog<bool>(
     context: context,
     builder: (context) => AlertDialog(
       title: Text('Delete Note'),
       actions: [
         TextButton(label: 'Cancel', onPressed: pop(false)),
         TextButton(label: 'Delete', onPressed: pop(true)),
       ],
     ),
   )
   ```

   Always confirm destructive actions!

3. **Smart Date Formatting**:

   ```dart
   if (difference == 0) return 'Today at 14:30';
   if (difference == 1) return 'Yesterday';
   if (difference < 7) return '$difference days ago';
   if (difference < 30) return '${difference ~/ 7} weeks ago';
   ```

   Makes the interface feel more natural.

4. **Color Scheme Theming**:

   ```dart
   theme: ThemeData(
     useMaterial3: true,
     colorScheme: ColorScheme.fromSeed(
       seedColor: Color(0xFF2196F3),
     ),
   )
   ```

   One seed color generates a complete, professional palette!

5. **Card Styling**:
   ```dart
   cardTheme: CardTheme(
     elevation: 1,
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(12),
     ),
   )
   ```
   Subtle shadows and rounded corners feel modern.

**Challenges:**

1. **confirmDismiss Return Type**: Must return `Future<bool>`, not just `bool`. Solved with `showDialog<bool>`.

2. **Key for Dismissible**: Each dismissible needs a unique key. Used `Key(note.id)`.

**Code Highlights:**

The confirmation dialog is well-designed:

```dart
AlertDialog(
  title: const Text('Delete Note'),
  content: const Text(
    'Are you sure? This action cannot be undone.',
  ),
  actions: [
    TextButton(onPressed: cancel, child: Text('Cancel')),
    TextButton(
      onPressed: confirm,
      style: TextButton.styleFrom(foregroundColor: Colors.red),
      child: Text('Delete'),
    ),
  ],
)
```

Red color on delete button is a UX best practice!

**Tomorrow's Plan:**
Day 8 starts the Bible verse detection feature with a comprehensive Bible reference parser.

**Stats Today:**

- 📁 Files modified: 2 (list page, main)
- 📁 Files created: 2 (bible entities)
- 📝 Lines of code: ~150
- ⏱️ Time spent: ~40 minutes
- 🚀 Progress: Core app complete! 🎉

**Key Insight:**
After 7 days, I have a complete, functional note-taking app with:

- ✅ Beautiful UI
- ✅ Complete CRUD operations
- ✅ Professional error handling
- ✅ Confirmation dialogs
- ✅ Clean Architecture

The next 3 days add the advanced feature: intelligent Bible verse detection!

---

## 🎯 Key Takeaways

✅ **Dismissible provides native swipe gestures**
✅ **Always confirm destructive actions**
✅ **Smart formatting improves UX**
✅ **Theming makes the app feel professional**

**Next**: Day 8 - Bible Reference Parser
