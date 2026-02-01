import 'package:equatable/equatable.dart';

class CloudBackup extends Equatable {
  final String id;
  final String userId;
  final String deviceId;
  final DateTime createdAt;
  final DateTime lastSyncAt;
  final int noteCount;
  final String backupUrl;
  final bool isComplete;
  final String status; // 'pending', 'syncing', 'complete', 'failed'
  final String? errorMessage;

  const CloudBackup({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.createdAt,
    required this.lastSyncAt,
    required this.noteCount,
    required this.backupUrl,
    required this.isComplete,
    required this.status,
    this.errorMessage,
  });

  CloudBackup copyWith({
    String? id,
    String? userId,
    String? deviceId,
    DateTime? createdAt,
    DateTime? lastSyncAt,
    int? noteCount,
    String? backupUrl,
    bool? isComplete,
    String? status,
    String? errorMessage,
  }) {
    return CloudBackup(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      noteCount: noteCount ?? this.noteCount,
      backupUrl: backupUrl ?? this.backupUrl,
      isComplete: isComplete ?? this.isComplete,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    deviceId,
    createdAt,
    lastSyncAt,
    noteCount,
    backupUrl,
    isComplete,
    status,
    errorMessage,
  ];
}
