# 10-Day Flutter Streak Plan: Day 4

## 📅 Day 4: BLoC Setup & State Management

### 🎯 Learning Goals

- Understand the BLoC pattern (Business Logic Component)
- Learn how events trigger state changes
- Implement states for all CRUD operations
- Build event handlers for business operations
- Auto-reload data after mutations
- Understand BLoC lifecycle

### 📝 What You'll Build

Today you'll create the NotesBloc that manages all state for notes in your app. This is where business logic meets the UI.

---

### Step 1: Create Notes Events

**File**: `lib/presentation/bloc/notes/notes_event.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/note.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

/// Load all notes from database
class LoadNotes extends NotesEvent {
  const LoadNotes();
}

/// Add a new note
class AddNoteEvent extends NotesEvent {
  final Note note;

  const AddNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

/// Update an existing note
class UpdateNoteEvent extends NotesEvent {
  final Note note;

  const UpdateNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

/// Delete a note
class DeleteNoteEvent extends NotesEvent {
  final String noteId;

  const DeleteNoteEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Search notes by query
class SearchNotesEvent extends NotesEvent {
  final String query;

  const SearchNotesEvent(this.query);

  @override
  List<Object?> get props => [query];
}
```

**🎓 What You're Learning:**

- **Events**: User actions or system triggers
- **Equatable**: Compare events by value for state consistency
- **Event Props**: What makes two events the same

---

### Step 2: Create Notes States

**File**: `lib/presentation/bloc/notes/notes_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/note.dart';

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

/// Initial state when app starts
class NotesInitial extends NotesState {}

/// Notes are being loaded from database
class NotesLoading extends NotesState {}

/// Notes successfully loaded
class NotesLoaded extends NotesState {
  final List<Note> notes;

  const NotesLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}

/// Operation (add/update/delete) completed successfully
class NoteOperationSuccess extends NotesState {
  final String message;

  const NoteOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error occurred during operation
class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object?> get props => [message];
}
```

**🎓 What You're Learning:**

- **States**: UI representations of data states
- **Loading State**: Show spinner while fetching
- **Loaded State**: Display data
- **Success State**: Notify user of successful operation
- **Error State**: Display error message

---

### Step 3: Create Notes BLoC

**File**: `lib/presentation/bloc/notes/notes_bloc.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/usecases/add_note.dart';
import '../../../domain/usecases/delete_note.dart';
import '../../../domain/usecases/get_notes.dart';
import '../../../domain/usecases/search_notes.dart';
import '../../../domain/usecases/update_note.dart';
import 'notes_event.dart';
import 'notes_state.dart';

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
    // Register event handlers
    on<LoadNotes>(_onLoadNotes);
    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<SearchNotesEvent>(_onSearchNotes);
  }

  /// Load all notes from database
  Future<void> _onLoadNotes(
    LoadNotes event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());

    final result = await getNotes(NoParams());

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (notes) => emit(NotesLoaded(notes)),
    );
  }

  /// Add a new note
  Future<void> _onAddNote(
    AddNoteEvent event,
    Emitter<NotesState> emit,
  ) async {
    final result = await addNote(AddNoteParams(event.note));

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (_) {
        emit(const NoteOperationSuccess('Note added successfully'));
        // Reload notes after adding
        add(const LoadNotes());
      },
    );
  }

  /// Update an existing note
  Future<void> _onUpdateNote(
    UpdateNoteEvent event,
    Emitter<NotesState> emit,
  ) async {
    final result = await updateNote(UpdateNoteParams(event.note));

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (_) {
        emit(const NoteOperationSuccess('Note updated successfully'));
        // Reload notes after updating
        add(const LoadNotes());
      },
    );
  }

  /// Delete a note
  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<NotesState> emit,
  ) async {
    final result = await deleteNote(DeleteNoteParams(event.noteId));

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (_) {
        emit(const NoteOperationSuccess('Note deleted successfully'));
        // Reload notes after deleting
        add(const LoadNotes());
      },
    );
  }

  /// Search notes by query
  Future<void> _onSearchNotes(
    SearchNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());

    final result = await searchNotes(SearchNotesParams(event.query));

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (notes) => emit(NotesLoaded(notes)),
    );
  }
}
```

**🎓 What You're Learning:**

- **Event Handlers**: Each event has a handler method
- **Emit**: Send state changes to UI
- **Fold**: Handle both failure and success cases
- **Auto-reload**: Call `add(LoadNotes())` after mutations
- **Dependency Injection**: All use cases injected into BLoC

---

### Step 4: Update Dependency Injection

**Modify**: `lib/core/di/injection_container.dart`

Add BLoC registration:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/notes/notes_bloc.dart';

Future<void> init() async {
  // ... existing code ...

  // BLoCs
  getIt.registerFactory(
    () => NotesBloc(
      getNotes: getIt(),
      addNote: getIt(),
      updateNote: getIt(),
      deleteNote: getIt(),
      searchNotes: getIt(),
    ),
  );
}
```

**Key Point**: BLoCs use `registerFactory` (new instance each time), not `registerLazySingleton`.

---

### 📦 Commit Your Work

```bash
git add .
git commit -m "Day 4: Implement BLoC for state management

- Created NotesEvent with LoadNotes, AddNote, UpdateNote, DeleteNote, SearchNotes
- Defined NotesState including Loading, Loaded, Success, Error states
- Implemented NotesBloc with event handlers for all CRUD operations
- Registered BLoC in dependency injection
- Auto-reload notes after operations

Learning: BLoC pattern separates business logic from UI. Predictable and testable!"

git push origin main
```

---

### 📖 Blog Entry: Day 4

**Title**: "State Management Mastery: Building the BLoC"

**What I Built Today:**
The BLoC is the heart of Flutter apps. Today I created:

- NotesEvent with 5 different event types
- NotesState with 5 different state representations
- NotesBloc that listens to events and emits states
- Complete CRUD event handlers

**What I Learned:**

1. **Event-Driven Architecture**:

   ```dart
   // User taps save button
   context.read<NotesBloc>().add(AddNoteEvent(newNote));

   // BLoC receives event, processes it
   on<AddNoteEvent>(_onAddNote);

   // BLoC emits new state
   emit(NoteOperationSuccess('Note added!'));

   // UI rebuilds automatically with new state
   ```

   This one-way flow makes the app predictable and debuggable.

2. **State vs Event Distinction**:
   - **Events**: What the user did
   - **States**: Current condition of the app

   `AddNoteEvent` → (processing) → `NoteOperationSuccess` state

3. **Auto-reload Pattern**:
   After adding/updating/deleting a note:

   ```dart
   emit(const NoteOperationSuccess('Note added!'));
   add(const LoadNotes());  // Automatically reload list
   ```

   This ensures the UI always shows latest data without manual refresh.

4. **Fold Pattern for Error Handling**:

   ```dart
   result.fold(
     (failure) => emit(NotesError(failure.message)),
     (data) => emit(NotesLoaded(data)),
   );
   ```

   Cleaner than try-catch, forces handling both cases.

5. **Factory vs Singleton for BLoCs**:
   ```dart
   getIt.registerFactory(() => NotesBloc(...))  // ✅ New instance each time
   getIt.registerLazySingleton(() => NotesBloc(...))  // ❌ Reused instance
   ```
   BLoCs should be factories so each screen gets its own instance.

**Challenges:**

1. **Understanding Emit**: Initially confused about when to emit states. Learned that every operation should emit some state (loading → result/error).

2. **Auto-reload Logic**: Struggled with how to reload notes after operations. Solution: `add(LoadNotes())` at the end of handlers.

3. **Proper Error Handling**: Needed to ensure every error path emits an error state so UI shows something to the user.

**Code Highlights:**

The event handler pattern is elegant:

```dart
on<AddNoteEvent>(_onAddNote);
on<UpdateNoteEvent>(_onUpdateNote);
on<DeleteNoteEvent>(_onDeleteNote);
// ... more handlers
```

Each handler is a pure function:

```dart
Future<void> _onAddNote(AddNoteEvent event, Emitter<NotesState> emit) async {
  final result = await addNote(AddNoteParams(event.note));
  result.fold(
    (failure) => emit(NotesError(failure.message)),
    (_) {
      emit(const NoteOperationSuccess('Note added successfully'));
      add(const LoadNotes());
    },
  );
}
```

**Tomorrow's Plan:**
Day 5 I'll build the UI! Time to see this state management in action with BlocBuilder.

**Stats Today:**

- 📁 Files created: 3 (events, states, bloc)
- 📝 Lines of code: ~250
- ⏱️ Time spent: ~45 minutes
- 🚀 Progress: State management complete!

**Key Insight:**
The beauty of BLoC is that it completely decouples business logic from UI. I could test these event handlers with zero Flutter widgets. The handlers just call use cases and emit states. That's testability!

---

## 🎯 Key Takeaways

✅ **BLoC pattern separates logic from UI**
✅ **Events drive state changes**
✅ **Auto-reload ensures data consistency**
✅ **Fold pattern handles errors elegantly**

**Next**: Day 5 - Building the Notes List UI
