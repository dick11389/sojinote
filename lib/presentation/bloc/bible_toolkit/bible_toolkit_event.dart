import 'package:equatable/equatable.dart';

abstract class BibleToolkitEvent extends Equatable {
  const BibleToolkitEvent();

  @override
  List<Object> get props => [];
}

class DetectVersesInText extends BibleToolkitEvent {
  final String text;

  const DetectVersesInText(this.text);

  @override
  List<Object> get props => [text];
}
