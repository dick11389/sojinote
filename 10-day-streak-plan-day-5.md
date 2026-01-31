# 10-Day Flutter Streak Plan: Day 5

## 📅 Day 5: Building the Notes List UI

### 🎯 Learning Goals

- Understand BlocBuilder for reactive UI
- Implement state-based UI rendering
- Build empty, loading, error, and loaded states
- Create beautiful note cards
- Handle user interactions
- Learn Material Design 3

### 📝 What You'll Build

Today you'll create the main screen showing all sermon notes. This is where the BLoC state management comes to life visually!

---

### Step 1: Create Notes List Page

**File**: `lib/presentation/pages/notes_list_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection_container.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes/notes_bloc.dart';
import '../bloc/notes/notes_event.dart';
import '../bloc/notes/notes_state.dart';
import 'sermon_editor_screen.dart';

class NotesListPage extends StatefulWidget {
  const NotesListPage({super.key});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  @override
  void initState() {
    super.initState();
    // Load notes when page opens
    context.read<NotesBloc>().add(const LoadNotes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sermon Notes'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality will be added later
              showSearch(
                context: context,
                delegate: NotesSearchDelegate(context.read<NotesBloc>()),
              );
            },
          ),
        ],
      ),
      body: BlocListener<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NoteOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {
            if (state is NotesLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is NotesLoaded) {
              return _buildNotesList(context, state.notes);
            } else if (state is NotesError) {
              return _buildErrorState(context, state.message);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SermonEditorScreen(),
            ),
          );

          // Reload notes if user saved something
          if (result == true && mounted) {
            context.read<NotesBloc>().add(const LoadNotes());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, List<Note> notes) {
    if (notes.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(context, note);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first sermon note',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading notes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<NotesBloc>().add(const LoadNotes());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    return Card(
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
              builder: (context) => SermonEditorScreen(note: note),
            ),
          );

          // Reload notes if user made changes
          if (result == true && mounted) {
            context.read<NotesBloc>().add(const LoadNotes());
          }
        },
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

/// Search delegate for searching notes
class NotesSearchDelegate extends SearchDelegate<String> {
  final NotesBloc notesBloc;

  NotesSearchDelegate(this.notesBloc);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Enter search query'),
      );
    }

    notesBloc.add(SearchNotesEvent(query));

    return BlocBuilder<NotesBloc, NotesState>(
      bloc: notesBloc,
      builder: (context, state) {
        if (state is NotesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is NotesLoaded) {
          if (state.notes.isEmpty) {
            return const Center(child: Text('No results found'));
          }
          return ListView.builder(
            itemCount: state.notes.length,
            itemBuilder: (context, index) {
              final note = state.notes[index];
              return ListTile(
                title: Text(note.title),
                subtitle: Text(note.content),
                onTap: () => close(context, note.id),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Search your sermon notes'),
    );
  }
}
```

**🎓 What You're Learning:**

- **BlocListener**: For one-time actions like snackbars
- **BlocBuilder**: For rebuilding UI on state changes
- **State Matching**: Different UI for each state
- **Material Design 3**: Modern Flutter design
- **ListTile and Card**: Built-in Material widgets

---

### Step 2: Update main.dart

**Modify**: `lib/main.dart`

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
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: BlocProvider(
        create: (_) => getIt<NotesBloc>(),
        child: const NotesListPage(),
      ),
    );
  }
}
```

---

### Step 3: Create Placeholder Editor Screen

**File**: `lib/presentation/pages/sermon_editor_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../../domain/entities/note.dart';

class SermonEditorScreen extends StatefulWidget {
  final Note? note;

  const SermonEditorScreen({
    super.key,
    this.note,
  });

  @override
  State<SermonEditorScreen> createState() => _SermonEditorScreenState();
}

class _SermonEditorScreenState extends State<SermonEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.note?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Save functionality coming tomorrow
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 📦 Commit Your Work

```bash
git add .
git commit -m "Day 5: Build notes list UI with BlocBuilder

- Created NotesListPage with responsive design
- Implemented empty state with helpful message
- Added loading state with CircularProgressIndicator
- Built error state with retry button
- Designed note cards with title, preview, date
- Connected BLoC to UI using BlocBuilder
- Added search functionality with SearchDelegate
- Updated main.dart to initialize BLoC

Learning: BlocBuilder automatically rebuilds when state changes!"

git push origin main
```

---

### 📖 Blog Entry: Day 5

**Title**: "Building the UI: From BLoC State to Pixel Perfect Design"

**What I Built Today:**
Today was exciting! The app finally looks like an app! I created:

- NotesListPage with beautiful note cards
- BlocBuilder and BlocListener for reactive UI
- Empty, loading, and error states
- Smart date formatting
- Search functionality
- Main.dart with BLoC provider

**What I Learned:**

1. **BlocListener vs BlocBuilder**:

   ```dart
   BlocListener(
     listener: (context, state) {
       if (state is NoteOperationSuccess) {
         ScaffoldMessenger.of(context).showSnackBar(...);
       }
     },
   )  // One-time actions

   BlocBuilder(
     builder: (context, state) {
       return state is NotesLoaded ? NotesList() : Spinner();
     },
   )  // UI rebuilds on every state change
   ```

2. **State-Based UI Rendering**:

   ```dart
   if (state is NotesLoading) return Spinner();
   if (state is NotesLoaded) return NotesList(state.notes);
   if (state is NotesError) return ErrorMessage(state.message);
   ```

   This pattern makes the app predictable and testable.

3. **Material Design 3**:
   Using `colorScheme: ColorScheme.fromSeed()` gives the app a modern look automatically. No custom colors needed!

4. **Proper ListTile Usage**:

   ```dart
   ListTile(
     title: Text(note.title),
     subtitle: Text(note.content),
     trailing: Icon(Icons.chevron_right),
     onTap: () { /* navigate */ },
   )
   ```

   Material Design provides professional-looking list items out of the box.

5. **Smart Date Formatting**:
   ```dart
   if (difference == 0) return 'Today';
   if (difference == 1) return 'Yesterday';
   if (difference < 7) return '$difference days ago';
   return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
   ```
   Makes the UI more human-readable.

**Challenges:**

1. **BlocProvider Setup**: Initially forgot to wrap the home with `BlocProvider`. Without it, the BLoC isn't accessible to the widget tree.

2. **LoadNotes on Init**: Needed to call `LoadNotes` in `initState` to fetch data when the page opens.

3. **Navigation Passing Results**: Needed to handle `Navigator.pop(context, true)` to know when to reload.

**Code Highlights:**

The empty state is beautiful and helpful:

```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.note_outlined, size: 64, color: Colors.grey[400]),
      SizedBox(height: 16),
      Text('No notes yet', style: headlineSmall),
      SizedBox(height: 8),
      Text('Tap the + button to create your first sermon note'),
    ],
  ),
)
```

Instead of just showing an empty list, I guide the user toward action.

**Tomorrow's Plan:**
Day 6 I'll make the editor actually work! Save notes to the database using the BLoC.

**Stats Today:**

- 📁 Files created: 2 (list page, editor skeleton)
- 📝 Lines of code: ~400
- ⏱️ Time spent: ~60 minutes
- 🚀 Progress: App is now runnable! 🎉

**Key Insight:**
The app is now running end-to-end. You tap the FAB, navigate to editor, tap back. The architecture is complete. Tomorrow I just need to wire up the save functionality and the core CRUD is done!

---

## 🎯 Key Takeaways

✅ **BlocBuilder makes reactive UIs simple**
✅ **Empty states improve UX**
✅ **Material Design 3 looks professional**
✅ **State-based rendering is predictable**

**Next**: Day 6 - Note Editor Screen
