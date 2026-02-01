import 'package:equatable/equatable.dart';

class AudioRecording extends Equatable {
  final String id;
  final String noteId;
  final String filePath;
  final Duration duration;
  final DateTime recordedAt;
  final String? title;
  final String? transcription;
  final double fileSize; // in MB
  final bool isProcessing;
  final String? processingStatus; // 'transcribing', 'complete'

  const AudioRecording({
    required this.id,
    required this.noteId,
    required this.filePath,
    required this.duration,
    required this.recordedAt,
    this.title,
    this.transcription,
    required this.fileSize,
    required this.isProcessing,
    this.processingStatus,
  });

  AudioRecording copyWith({
    String? id,
    String? noteId,
    String? filePath,
    Duration? duration,
    DateTime? recordedAt,
    String? title,
    String? transcription,
    double? fileSize,
    bool? isProcessing,
    String? processingStatus,
  }) {
    return AudioRecording(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      recordedAt: recordedAt ?? this.recordedAt,
      title: title ?? this.title,
      transcription: transcription ?? this.transcription,
      fileSize: fileSize ?? this.fileSize,
      isProcessing: isProcessing ?? this.isProcessing,
      processingStatus: processingStatus ?? this.processingStatus,
    );
  }

  @override
  List<Object?> get props => [
    id,
    noteId,
    filePath,
    duration,
    recordedAt,
    title,
    transcription,
    fileSize,
    isProcessing,
    processingStatus,
  ];
}
