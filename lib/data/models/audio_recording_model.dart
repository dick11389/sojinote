import '../../domain/entities/audio_recording.dart';

class AudioRecordingModel extends AudioRecording {
  const AudioRecordingModel({
    required String id,
    required String noteId,
    required String filePath,
    required Duration duration,
    required DateTime recordedAt,
    String? title,
    String? transcription,
    required double fileSize,
    required bool isProcessing,
    String? processingStatus,
  }) : super(
    id: id,
    noteId: noteId,
    filePath: filePath,
    duration: duration,
    recordedAt: recordedAt,
    title: title,
    transcription: transcription,
    fileSize: fileSize,
    isProcessing: isProcessing,
    processingStatus: processingStatus,
  );

  factory AudioRecordingModel.fromJson(Map<String, dynamic> json) {
    return AudioRecordingModel(
      id: json['id'] as String,
      noteId: json['noteId'] as String,
      filePath: json['filePath'] as String,
      duration: Duration(milliseconds: json['durationMs'] as int),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      title: json['title'] as String?,
      transcription: json['transcription'] as String?,
      fileSize: (json['fileSize'] as num).toDouble(),
      isProcessing: json['isProcessing'] as bool,
      processingStatus: json['processingStatus'] as String?,
    );
  }

  factory AudioRecordingModel.fromDatabase(Map<String, dynamic> map) {
    return AudioRecordingModel(
      id: map['id'] as String,
      noteId: map['noteId'] as String,
      filePath: map['filePath'] as String,
      duration: Duration(milliseconds: map['durationMs'] as int),
      recordedAt: DateTime.parse(map['recordedAt'] as String),
      title: map['title'] as String?,
      transcription: map['transcription'] as String?,
      fileSize: (map['fileSize'] as num).toDouble(),
      isProcessing: map['isProcessing'] == 1,
      processingStatus: map['processingStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'noteId': noteId,
    'filePath': filePath,
    'durationMs': duration.inMilliseconds,
    'recordedAt': recordedAt.toIso8601String(),
    'title': title,
    'transcription': transcription,
    'fileSize': fileSize,
    'isProcessing': isProcessing,
    'processingStatus': processingStatus,
  };

  Map<String, dynamic> toDatabase() => {
    'id': id,
    'noteId': noteId,
    'filePath': filePath,
    'durationMs': duration.inMilliseconds,
    'recordedAt': recordedAt.toIso8601String(),
    'title': title,
    'transcription': transcription,
    'fileSize': fileSize,
    'isProcessing': isProcessing ? 1 : 0,
    'processingStatus': processingStatus,
  };
}
