import 'package:sqflite/sqflite.dart';
import '../../domain/entities/audio_recording.dart';
import '../models/audio_recording_model.dart';

abstract class AudioDatasource {
  Future<AudioRecordingModel> createRecording(
    String noteId,
    String filePath,
    Duration duration,
    double fileSize,
  );
  Future<List<AudioRecordingModel>> getRecordingsByNoteId(String noteId);
  Future<AudioRecordingModel?> getRecordingById(String recordingId);
  Future<void> deleteRecording(String recordingId);
  Future<void> updateRecordingTranscription(String recordingId, String transcription);
  Future<void> updateRecordingTitle(String recordingId, String title);
}

class AudioDatasourceImpl implements AudioDatasource {
  final Database database;

  AudioDatasourceImpl({required this.database});

  @override
  Future<AudioRecordingModel> createRecording(
    String noteId,
    String filePath,
    Duration duration,
    double fileSize,
  ) async {
    final recordingId = 'audio_${DateTime.now().millisecondsSinceEpoch}';
    final recording = AudioRecordingModel(
      id: recordingId,
      noteId: noteId,
      filePath: filePath,
      duration: duration,
      recordedAt: DateTime.now(),
      fileSize: fileSize,
      isProcessing: false,
    );
    await database.insert('audio_recordings', recording.toDatabase());
    return recording;
  }

  @override
  Future<List<AudioRecordingModel>> getRecordingsByNoteId(String noteId) async {
    final result = await database.query(
      'audio_recordings',
      where: 'noteId = ?',
      whereArgs: [noteId],
      orderBy: 'recordedAt DESC',
    );
    return result.map((map) => AudioRecordingModel.fromDatabase(map)).toList();
  }

  @override
  Future<AudioRecordingModel?> getRecordingById(String recordingId) async {
    final result = await database.query(
      'audio_recordings',
      where: 'id = ?',
      whereArgs: [recordingId],
    );
    if (result.isNotEmpty) {
      return AudioRecordingModel.fromDatabase(result.first);
    }
    return null;
  }

  @override
  Future<void> deleteRecording(String recordingId) async {
    await database.delete(
      'audio_recordings',
      where: 'id = ?',
      whereArgs: [recordingId],
    );
  }

  @override
  Future<void> updateRecordingTranscription(String recordingId, String transcription) async {
    await database.update(
      'audio_recordings',
      {
        'transcription': transcription,
        'isProcessing': 0,
        'processingStatus': 'complete',
      },
      where: 'id = ?',
      whereArgs: [recordingId],
    );
  }

  @override
  Future<void> updateRecordingTitle(String recordingId, String title) async {
    await database.update(
      'audio_recordings',
      {'title': title},
      where: 'id = ?',
      whereArgs: [recordingId],
    );
  }
}
