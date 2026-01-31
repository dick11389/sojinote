import 'package:equatable/equatable.dart';

class BibleVerse extends Equatable {
  final String reference;
  final String text;
  final String book;
  final int chapter;
  final int verse;

  const BibleVerse({
    required this.reference,
    required this.text,
    required this.book,
    required this.chapter,
    required this.verse,
  });

  @override
  List<Object> get props => [reference, text, book, chapter, verse];
}
