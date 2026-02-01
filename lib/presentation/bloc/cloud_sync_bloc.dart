import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/cloud_sync_usecases.dart';
import '../../domain/entities/cloud_backup.dart';
import '../../core/error/failures.dart';

// Events
abstract class CloudSyncEvent extends Equatable {
  const CloudSyncEvent();

  @override
  List<Object?> get props => [];
}

class SyncNotesToCloudEvent extends CloudSyncEvent {
  const SyncNotesToCloudEvent();
}

class GetCloudBackupStatusEvent extends CloudSyncEvent {
  const GetCloudBackupStatusEvent();
}

class EnableAutoSyncEvent extends CloudSyncEvent {
  final int intervalMinutes;

  const EnableAutoSyncEvent(this.intervalMinutes);

  @override
  List<Object?> get props => [intervalMinutes];
}

class DisableAutoSyncEvent extends CloudSyncEvent {
  const DisableAutoSyncEvent();
}

class RestoreFromBackupEvent extends CloudSyncEvent {
  final String backupId;

  const RestoreFromBackupEvent(this.backupId);

  @override
  List<Object?> get props => [backupId];
}

// States
abstract class CloudSyncState extends Equatable {
  const CloudSyncState();

  @override
  List<Object?> get props => [];
}

class CloudSyncInitial extends CloudSyncState {
  const CloudSyncInitial();
}

class CloudSyncLoading extends CloudSyncState {
  const CloudSyncLoading();
}

class CloudSyncSuccess extends CloudSyncState {
  final CloudBackup backup;

  const CloudSyncSuccess(this.backup);

  @override
  List<Object?> get props => [backup];
}

class CloudSyncError extends CloudSyncState {
  final String message;

  const CloudSyncError(this.message);

  @override
  List<Object?> get props => [message];
}

class AutoSyncEnabled extends CloudSyncState {
  final int intervalMinutes;

  const AutoSyncEnabled(this.intervalMinutes);

  @override
  List<Object?> get props => [intervalMinutes];
}

// BLoC
class CloudSyncBloc extends Bloc<CloudSyncEvent, CloudSyncState> {
  final SyncNotesToCloud syncNotesToCloud;
  final GetCloudBackupStatus getBackupStatus;
  final EnableAutoSync enableAutoSync;
  final DisableAutoSync disableAutoSync;
  final RestoreNotesFromCloud restoreFromCloud;

  CloudSyncBloc({
    required this.syncNotesToCloud,
    required this.getBackupStatus,
    required this.enableAutoSync,
    required this.disableAutoSync,
    required this.restoreFromCloud,
  }) : super(const CloudSyncInitial()) {
    on<SyncNotesToCloudEvent>(_onSyncNotesToCloud);
    on<GetCloudBackupStatusEvent>(_onGetBackupStatus);
    on<EnableAutoSyncEvent>(_onEnableAutoSync);
    on<DisableAutoSyncEvent>(_onDisableAutoSync);
    on<RestoreFromBackupEvent>(_onRestoreFromBackup);
  }

  Future<void> _onSyncNotesToCloud(
    SyncNotesToCloudEvent event,
    Emitter<CloudSyncState> emit,
  ) async {
    emit(const CloudSyncLoading());
    final result = await syncNotesToCloud(NoParams());
    result.fold(
      (failure) => emit(CloudSyncError(_failureToString(failure))),
      (backup) => emit(CloudSyncSuccess(backup)),
    );
  }

  Future<void> _onGetBackupStatus(
    GetCloudBackupStatusEvent event,
    Emitter<CloudSyncState> emit,
  ) async {
    emit(const CloudSyncLoading());
    final result = await getBackupStatus(NoParams());
    result.fold(
      (failure) => emit(CloudSyncError(_failureToString(failure))),
      (backup) => emit(CloudSyncSuccess(backup)),
    );
  }

  Future<void> _onEnableAutoSync(
    EnableAutoSyncEvent event,
    Emitter<CloudSyncState> emit,
  ) async {
    emit(const CloudSyncLoading());
    final result = await enableAutoSync(event.intervalMinutes);
    result.fold(
      (failure) => emit(CloudSyncError(_failureToString(failure))),
      (_) => emit(AutoSyncEnabled(event.intervalMinutes)),
    );
  }

  Future<void> _onDisableAutoSync(
    DisableAutoSyncEvent event,
    Emitter<CloudSyncState> emit,
  ) async {
    emit(const CloudSyncLoading());
    final result = await disableAutoSync(NoParams());
    result.fold(
      (failure) => emit(CloudSyncError(_failureToString(failure))),
      (_) => emit(const CloudSyncInitial()),
    );
  }

  Future<void> _onRestoreFromBackup(
    RestoreFromBackupEvent event,
    Emitter<CloudSyncState> emit,
  ) async {
    emit(const CloudSyncLoading());
    final result = await restoreFromCloud(event.backupId);
    result.fold(
      (failure) => emit(CloudSyncError(_failureToString(failure))),
      (_) => emit(const CloudSyncSuccess(CloudBackup(
        id: 'restored',
        userId: 'user',
        deviceId: 'device',
        createdAt: DateTime.now(),
        lastSyncAt: DateTime.now(),
        noteCount: 0,
        backupUrl: '',
        isComplete: true,
        status: 'restored',
      ))),
    );
  }

  String _failureToString(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server error occurred';
    } else if (failure is CacheFailure) {
      return 'Cache error occurred';
    }
    return 'An unexpected error occurred';
  }
}
