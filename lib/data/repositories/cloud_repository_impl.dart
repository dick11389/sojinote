import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/cloud_backup.dart';
import '../../domain/repositories/cloud_repository.dart';
import '../datasources/cloud_datasource.dart';

class CloudRepositoryImpl implements CloudRepository {
  final CloudLocalDatasource localDatasource;
  final CloudRemoteDatasource remoteDatasource;

  CloudRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  @override
  Future<Either<Failure, CloudBackup>> syncNotesToCloud() async {
    try {
      // Get all notes from local database
      final notes = <Map<String, dynamic>>[]; // Fetch from note repository
      
      // Sync to cloud
      final backup = await remoteDatasource.syncNotesToCloud(notes);
      
      // Save backup status locally
      await localDatasource.saveBackupStatus(backup);
      
      return Right(backup);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, CloudBackup>> getBackupStatus() async {
    try {
      final backup = await localDatasource.getBackupStatus();
      if (backup != null) {
        return Right(backup);
      }
      return Left(NotFoundFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> restoreFromBackup(String backupId) async {
    try {
      final result = await remoteDatasource.restoreFromBackup(backupId);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> enableAutoSync(int intervalMinutes) async {
    try {
      // Schedule periodic sync task
      // Implementation depends on background task package
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> disableAutoSync() async {
    try {
      // Cancel periodic sync task
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
