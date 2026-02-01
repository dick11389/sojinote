import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/cloud_backup.dart';
import '../../domain/repositories/cloud_repository.dart';

class SyncNotesToCloud implements UseCase<CloudBackup, NoParams> {
  final CloudRepository repository;

  SyncNotesToCloud(this.repository);

  @override
  Future<Either<Failure, CloudBackup>> call(NoParams params) async {
    return await repository.syncNotesToCloud();
  }
}

class GetCloudBackupStatus implements UseCase<CloudBackup, NoParams> {
  final CloudRepository repository;

  GetCloudBackupStatus(this.repository);

  @override
  Future<Either<Failure, CloudBackup>> call(NoParams params) async {
    return await repository.getBackupStatus();
  }
}

class RestoreNotesFromCloud implements UseCase<bool, String> {
  final CloudRepository repository;

  RestoreNotesFromCloud(this.repository);

  @override
  Future<Either<Failure, bool>> call(String backupId) async {
    return await repository.restoreFromBackup(backupId);
  }
}

class EnableAutoSync implements UseCase<bool, int> {
  final CloudRepository repository;

  EnableAutoSync(this.repository);

  @override
  Future<Either<Failure, bool>> call(int intervalMinutes) async {
    return await repository.enableAutoSync(intervalMinutes);
  }
}

class DisableAutoSync implements UseCase<bool, NoParams> {
  final CloudRepository repository;

  DisableAutoSync(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.disableAutoSync();
  }
}
