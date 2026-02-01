import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/audio_recording.dart';

abstract class AudioRepository {
  Future<Either<Failure, bool>> startRecording(String noteId);
  Future<Either<Failure, AudioRecording>> stopRecording();
  Future<Either<Failure, List<AudioRecording>>> getRecordingsByNoteId(String noteId);
  Future<Either<Failure, bool>> playRecording(String recordingId);
  Future<Either<Failure, bool>> deleteRecording(String recordingId);
  Future<Either<Failure, String>> transcribeRecording(String recordingId);
  Future<Either<Failure, bool>> updateRecordingTitle(String recordingId, String title);
}
