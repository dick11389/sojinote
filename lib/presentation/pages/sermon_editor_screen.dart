import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection_container.dart' as di;
import '../../domain/entities/note.dart';
import '../bloc/bible_toolkit/bible_toolkit_bloc.dart';
import '../bloc/bible_toolkit/bible_toolkit_event.dart';
import '../bloc/bible_toolkit/bible_toolkit_state.dart';
import '../widgets/verse_preview_button.dart';
import '../widgets/verse_preview_dialog.dart';

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
  late FocusNode _contentFocusNode;
  
  Offset? _previewButtonPosition;
  List<String> _detectedVerses = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _contentFocusNode = FocusNode();
    
    // Listen to cursor position changes
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    // Update preview button position when cursor moves
    if (_detectedVerses.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updatePreviewButtonPosition();
      });
    }
  }

  void _updatePreviewButtonPosition() {
    if (!mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Get cursor position
    final selection = _contentController.selection;
    if (!selection.isValid) return;

    setState(() {
      // Position the button near the cursor
      // This is a simplified version - you might want to calculate exact position
      _previewButtonPosition = Offset(
        renderBox.size.width - 80, // Right side
        200, // Approximate position
      );
    });
  }

  String _getCurrentLine() {
    final text = _contentController.text;
    final cursorPosition = _contentController.selection.baseOffset;
    
    if (cursorPosition < 0 || text.isEmpty) return '';

    // Find the start of the current line
    int lineStart = text.lastIndexOf('\n', cursorPosition - 1) + 1;
    
    // Find the end of the current line
    int lineEnd = text.indexOf('\n', cursorPosition);
    if (lineEnd == -1) lineEnd = text.length;

    return text.substring(lineStart, lineEnd);
  }

  void _showVersePreview(BuildContext context, String verse) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<BibleToolkitBloc>(),
        child: VersePreviewDialog(verseReference: verse),
      ),
    );
  }

  void _saveNote() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    // TODO: Implement save functionality using NotesBloc
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<BibleToolkitBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.note == null ? 'New Sermon Note' : 'Edit Note'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveNote,
              tooltip: 'Save',
            ),
          ],
        ),
        body: BlocListener<BibleToolkitBloc, BibleToolkitState>(
          listener: (context, state) {
            if (state is VersesDetected) {
              setState(() {
                _detectedVerses = state.verses;
                if (_detectedVerses.isNotEmpty) {
                  _updatePreviewButtonPosition();
                }
              });
            }
          },
          child: Stack(
            children: [
              _buildEditorContent(context),
              if (_detectedVerses.isNotEmpty && _previewButtonPosition != null)
                _buildFloatingPreviewButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditorContent(BuildContext context) {
    return Column(
      children: [
        // Title Field
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Sermon Title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const Divider(height: 1),

        // Content Field with Debounce
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildDebouncedTextField(context),
          ),
        ),

        // Verse Detection Indicator
        BlocBuilder<BibleToolkitBloc, BibleToolkitState>(
          builder: (context, state) {
            if (state is VersesDetected && state.verses.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    const Icon(
                      Icons.book,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${state.verses.length} verse(s) detected: ${state.verses.join(", ")}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildDebouncedTextField(BuildContext context) {
    return StreamBuilder<String>(
      stream: _createDebouncedStream(),
      builder: (context, snapshot) {
        return TextField(
          controller: _contentController,
          focusNode: _contentFocusNode,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          decoration: const InputDecoration(
            hintText: 'Start typing your sermon notes...\n\nTip: Type Bible references like "John 3:16" and they will be automatically detected!',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(16),
          ),
          style: const TextStyle(fontSize: 16, height: 1.5),
          onChanged: (text) {
            // Trigger debounced detection
            final currentLine = _getCurrentLine();
            context.read<BibleToolkitBloc>().add(
              DetectVersesInText(currentLine),
            );
          },
        );
      },
    );
  }

  Stream<String> _createDebouncedStream() {
    // This is handled by the BLoC transformer with rxdart
    // The stream here is just for UI updates
    return Stream.value(_contentController.text);
  }

  Widget _buildFloatingPreviewButton(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 80,
      child: VersePreviewButton(
        verses: _detectedVerses,
        onPreview: (verse) => _showVersePreview(context, verse),
      ),
    );
  }
}
