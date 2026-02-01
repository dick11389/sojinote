import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/cloud_backup.dart';

abstract class CloudRepository {
  Future<Either<Failure, CloudBackup>> syncNotesToCloud();
  Future<Either<Failure, CloudBackup>> getBackupStatus();
  Future<Either<Failure, bool>> restoreFromBackup(String backupId);
  Future<Either<Failure, bool>> enableAutoSync(int intervalMinutes);
  Future<Either<Failure, bool>> disableAutoSync();
}
