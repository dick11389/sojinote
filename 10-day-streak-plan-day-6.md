# 10-Day Flutter Streak Plan: Day 6

## 📅 Day 6: Note Editor Screen

### 🎯 Learning Goals

- Implement form validation
- Use BlocListener for navigation
- Handle note creation and editing
- Learn TextEditingController lifecycle
- Implement proper form submission
- Use UUID for unique IDs

### 📝 What You'll Build

Today you'll complete the note editor where users can create new notes and edit existing ones. This completes the full CRUD circle!

---

### Step 1: Update Note Editor Screen

**Modify**: `lib/presentation/pages/sermon_editor_screen.dart`

Replace entire file with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../core/di/injection_container.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes/notes_bloc.dart';
import '../bloc/notes/notes_event.dart';
import '../bloc/notes/notes_state.dart';

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
  bool _isLoading = false;

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

  void _saveNote() {
    // Validation
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a title');
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter some content');
      return;
    }

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final note = Note(
      id: widget.note?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.note == null) {
      // Add new note
      context.read<NotesBloc>().add(AddNoteEvent(note));
    } else {
      // Update existing note
      context.read<NotesBloc>().add(UpdateNoteEvent(note));
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state is NoteOperationSuccess) {
          Navigator.of(context).pop(true);
        } else if (state is NotesError) {
          setState(() => _isLoading = false);
          _showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.note == null ? 'New Sermon Note' : 'Edit Note',
          ),
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: _saveNote,
                      ),
              ),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Title field
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g., Sunday Service - January 15',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  maxLines: 1,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Content field
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: 'Content',
                      hintText: 'Write your sermon notes here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 100.0),
                        child: Icon(Icons.description),
                      ),
                    ),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**🎓 What You're Learning:**

- **Form Validation**: Check before submitting
- **BlocListener**: Used for navigation side effects
- **TextEditingController Lifecycle**: Dispose properly
- **UUID Generation**: Create unique IDs for new notes
- **Loading State**: Show spinner during save
- **Error Handling**: Display errors to user

---

### Step 2: Update Notes List to Handle Results

**Modify**: `lib/presentation/pages/notes_list_page.dart`

Update the note card tap handler:

```dart
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

  // Reload notes if user made changes
  if (result == true && mounted) {
    context.read<NotesBloc>().add(const LoadNotes());
  }
},
```

And the FAB handler:

```dart
floatingActionButton: FloatingActionButton(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => getIt<NotesBloc>(),
          child: const SermonEditorScreen(),
        ),
      ),
    );

    // Reload notes if user saved something
    if (result == true && mounted) {
      context.read<NotesBloc>().add(const LoadNotes());
    }
  },
  child: const Icon(Icons.add),
),
```

---

### 📦 Commit Your Work

```bash
git add .
git commit -m "Day 6: Implement note editor for create and edit

- Created SermonEditorScreen with title and content fields
- Implemented save functionality with validation
- Added loading indicator in save button
- Set up BlocListener for success/error feedback
- Configured navigation with result to reload notes list
- Enabled edit mode by passing existing note
- Used UUID for generating unique IDs

Learning: BlocListener for one-time actions like navigation/snackbars!"

git push origin main
```

---

### 📖 Blog Entry: Day 6

**Title**: "Complete CRUD Loop: Save, Update, and Return"

**What I Built Today:**
The complete CRUD circle is now functional! Users can:

- Create new sermon notes ✅
- Edit existing notes ✅
- See changes reflected immediately ✅

**What I Learned:**

1. **Form Validation Pattern**:

   ```dart
   void _saveNote() {
     if (_titleController.text.trim().isEmpty) {
       _showErrorSnackBar('Please enter a title');
       return;
     }
     // Continue with save
   }
   ```

   Fail fast with user-friendly messages.

2. **UUID for Unique IDs**:

   ```dart
   id: widget.note?.id ?? const Uuid().v4(),
   ```

   For new notes, generate a UUID. For existing notes, keep the ID.

3. **BlocListener for Navigation**:

   ```dart
   BlocListener<NotesBloc, NotesState>(
     listener: (context, state) {
       if (state is NoteOperationSuccess) {
         Navigator.of(context).pop(true);
       }
     },
   )
   ```

   Perfect for side effects like navigation that shouldn't rebuild the UI.

4. **DateTime Management**:

   ```dart
   final note = Note(
     createdAt: widget.note?.createdAt ?? now,  // Keep original
     updatedAt: now,  // Always update this
   );
   ```

   Only update the `updatedAt` field, preserve `createdAt`.

5. **Loading State Feedback**:
   ```dart
   _isLoading
       ? CircularProgressIndicator()
       : IconButton(icon: Icon(Icons.save))
   ```
   Show spinner instead of save button while saving.

**Challenges:**

1. **BlocListener not triggering**: Initially didn't wrap editor with `BlocListener`. Must be inside the BLoC's context.

2. **Note not reloading after save**: Had to add `add(LoadNotes())` in the list page after getting `result == true`.

3. **TextEditingController disposal**: Forgot to call `dispose()` initially, which would cause memory leaks.

**Code Highlights:**

The validation logic is clean:

```dart
if (_titleController.text.trim().isEmpty) {
  _showErrorSnackBar('Please enter a title');
  return;
}
```

This pattern prevents empty notes from being saved.

**Tomorrow's Plan:**
Day 7 adds delete functionality with swipe-to-delete and confirmation dialogs.

**Stats Today:**

- 📁 Files modified: 2 (editor, list page)
- 📝 Lines of code: ~200
- ⏱️ Time spent: ~40 minutes
- 🚀 Progress: Full CRUD working! 🎉

**Key Insight:**
The app now has a complete workflow:

1. User taps FAB
2. Editor opens
3. User enters title and content
4. User taps save
5. BLoC saves to database
6. Editor closes
7. List reloads automatically
8. User sees their new note!

The architecture makes this flow simple and predictable.

---

## 🎯 Key Takeaways

✅ **Form validation prevents bad data**
✅ **BlocListener handles side effects**
✅ **UUID ensures unique identifiers**
✅ **Proper TextEditingController lifecycle prevents memory leaks**

**Next**: Day 7 - Delete Functionality & Polish
