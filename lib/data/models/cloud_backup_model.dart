import '../../domain/entities/cloud_backup.dart';

class CloudBackupModel extends CloudBackup {
  const CloudBackupModel({
    required String id,
    required String userId,
    required String deviceId,
    required DateTime createdAt,
    required DateTime lastSyncAt,
    required int noteCount,
    required String backupUrl,
    required bool isComplete,
    required String status,
    String? errorMessage,
  }) : super(
    id: id,
    userId: userId,
    deviceId: deviceId,
    createdAt: createdAt,
    lastSyncAt: lastSyncAt,
    noteCount: noteCount,
    backupUrl: backupUrl,
    isComplete: isComplete,
    status: status,
    errorMessage: errorMessage,
  );

  factory CloudBackupModel.fromJson(Map<String, dynamic> json) {
    return CloudBackupModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      deviceId: json['deviceId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSyncAt: DateTime.parse(json['lastSyncAt'] as String),
      noteCount: json['noteCount'] as int,
      backupUrl: json['backupUrl'] as String,
      isComplete: json['isComplete'] as bool,
      status: json['status'] as String,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  factory CloudBackupModel.fromDatabase(Map<String, dynamic> map) {
    return CloudBackupModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      deviceId: map['deviceId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastSyncAt: DateTime.parse(map['lastSyncAt'] as String),
      noteCount: map['noteCount'] as int,
      backupUrl: map['backupUrl'] as String,
      isComplete: map['isComplete'] == 1,
      status: map['status'] as String,
      errorMessage: map['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'deviceId': deviceId,
    'createdAt': createdAt.toIso8601String(),
    'lastSyncAt': lastSyncAt.toIso8601String(),
    'noteCount': noteCount,
    'backupUrl': backupUrl,
    'isComplete': isComplete,
    'status': status,
    'errorMessage': errorMessage,
  };

  Map<String, dynamic> toDatabase() => {
    'id': id,
    'userId': userId,
    'deviceId': deviceId,
    'createdAt': createdAt.toIso8601String(),
    'lastSyncAt': lastSyncAt.toIso8601String(),
    'noteCount': noteCount,
    'backupUrl': backupUrl,
    'isComplete': isComplete ? 1 : 0,
    'status': status,
    'errorMessage': errorMessage,
  };
}
