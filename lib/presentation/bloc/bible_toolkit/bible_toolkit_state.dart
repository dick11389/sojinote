import 'package:equatable/equatable.dart';

abstract class BibleToolkitState extends Equatable {
  const BibleToolkitState();

  @override
  List<Object> get props => [];
}

class BibleToolkitInitial extends BibleToolkitState {}

class VersesDetected extends BibleToolkitState {
  final List<String> verses;

  const VersesDetected(this.verses);

  @override
  List<Object> get props => [verses];
}
