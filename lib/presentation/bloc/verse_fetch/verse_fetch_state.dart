import 'package:equatable/equatable.dart';
import '../../../domain/entities/bible_verse.dart';

abstract class VerseFetchState extends Equatable {
  const VerseFetchState();

  @override
  List<Object> get props => [];
}

class VerseFetchInitial extends VerseFetchState {}

class VerseFetchLoading extends VerseFetchState {}

class VerseFetchLoaded extends VerseFetchState {
  final BibleVerse verse;

  const VerseFetchLoaded(this.verse);

  @override
  List<Object> get props => [verse];
}

class VerseFetchError extends VerseFetchState {
  final String message;

  const VerseFetchError(this.message);

  @override
  List<Object> get props => [message];
}
