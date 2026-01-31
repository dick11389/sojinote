import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_verse.dart';
import 'verse_fetch_event.dart';
import 'verse_fetch_state.dart';

class VerseFetchBloc extends Bloc<VerseFetchEvent, VerseFetchState> {
  final GetVerse getVerse;

  VerseFetchBloc({required this.getVerse}) : super(VerseFetchInitial()) {
    on<FetchVerseEvent>(_onFetchVerse);
  }

  Future<void> _onFetchVerse(
    FetchVerseEvent event,
    Emitter<VerseFetchState> emit,
  ) async {
    emit(VerseFetchLoading());
    
    try {
      final verse = await getVerse(event.reference);
      emit(VerseFetchLoaded(verse));
    } catch (e) {
      emit(VerseFetchError(_getErrorMessage(e)));
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('internet')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (errorString.contains('not found') || errorString.contains('404')) {
      return 'Verse not found. Please check the reference and try again.';
    } else if (errorString.contains('timeout')) {
      return 'Connection timeout. Please try again.';
    } else if (errorString.contains('server')) {
      return 'Server error. Please try again later.';
    }
    
    return 'Unable to load verse. Please try again.';
  }
}
