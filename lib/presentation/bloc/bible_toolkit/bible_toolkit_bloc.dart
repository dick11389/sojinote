import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../../domain/usecases/detect_bible_verses.dart';
import '../../../domain/usecases/get_verse.dart';
import '../../../domain/utils/bible_reference_parser.dart';
import 'bible_toolkit_event.dart';
import 'bible_toolkit_state.dart';

class BibleToolkitBloc extends Bloc<BibleToolkitEvent, BibleToolkitState> {
  final DetectBibleVerses detectBibleVerses;
  final GetVerse getVerse;

  BibleToolkitBloc({
    required this.detectBibleVerses,
    required this.getVerse,
  }) : super(BibleToolkitInitial()) {
    on<DetectVersesInText>(
      _onDetectVerses,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .asyncExpand(mapper),
    );
  }

  Future<void> _onDetectVerses(
    DetectVersesInText event,
    Emitter<BibleToolkitState> emit,
  ) async {
    try {
      // Use the BibleReferenceParser to detect verses
      final references = BibleReferenceParser.parse(event.text);
      final verses = references.map((ref) => ref.formatted).toList();
      
      emit(VersesDetected(verses));
    } catch (e) {
      emit(const VersesDetected([]));
    }
  }
}
