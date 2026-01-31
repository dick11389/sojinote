import 'package:equatable/equatable.dart';

abstract class VerseFetchEvent extends Equatable {
  const VerseFetchEvent();

  @override
  List<Object> get props => [];
}

class FetchVerseEvent extends VerseFetchEvent {
  final String reference;

  const FetchVerseEvent(this.reference);

  @override
  List<Object> get props => [reference];
}
