import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/audio_recording.dart';
import '../../domain/repositories/audio_repository.dart';

class StartAudioRecording implements UseCase<bool, String> {
  final AudioRepository repository;

  StartAudioRecording(this.repository);

  @override
  Future<Either<Failure, bool>> call(String noteId) async {
    return await repository.startRecording(noteId);
  }
}

class StopAudioRecording implements UseCase<AudioRecording, NoParams> {
  final AudioRepository repository;

  StopAudioRecording(this.repository);

  @override
  Future<Either<Failure, AudioRecording>> call(NoParams params) async {
    return await repository.stopRecording();
  }
}

class GetAudioRecordings implements UseCase<List<AudioRecording>, String> {
  final AudioRepository repository;

  GetAudioRecordings(this.repository);

  @override
  Future<Either<Failure, List<AudioRecording>>> call(String noteId) async {
    return await repository.getRecordingsByNoteId(noteId);
  }
}

class PlayAudioRecording implements UseCase<bool, String> {
  final AudioRepository repository;

  PlayAudioRecording(this.repository);

  @override
  Future<Either<Failure, bool>> call(String recordingId) async {
    return await repository.playRecording(recordingId);
  }
}

class DeleteAudioRecording implements UseCase<bool, String> {
  final AudioRepository repository;

  DeleteAudioRecording(this.repository);

  @override
  Future<Either<Failure, bool>> call(String recordingId) async {
    return await repository.deleteRecording(recordingId);
  }
}

class TranscribeAudioRecording implements UseCase<String, String> {
  final AudioRepository repository;

  TranscribeAudioRecording(this.repository);

  @override
  Future<Either<Failure, String>> call(String recordingId) async {
    return await repository.transcribeRecording(recordingId);
  }
}

class UpdateAudioRecordingTitle implements UseCase<bool, UpdateAudioTitleParams> {
  final AudioRepository repository;

  UpdateAudioRecordingTitle(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdateAudioTitleParams params) async {
    return await repository.updateRecordingTitle(params.recordingId, params.title);
  }
}

// Parameters
class UpdateAudioTitleParams {
  final String recordingId;
  final String title;

  UpdateAudioTitleParams({required this.recordingId, required this.title});
}
