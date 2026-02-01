import '../../domain/entities/bible_translation.dart';

class BibleTranslationModel extends BibleTranslation {
  const BibleTranslationModel({
    required String id,
    required String code,
    required String name,
    required String abbreviation,
    required String language,
    String? description,
    required bool isDefault,
    required bool isDownloaded,
    DateTime? downloadedAt,
    String? apiEndpoint,
  }) : super(
    id: id,
    code: code,
    name: name,
    abbreviation: abbreviation,
    language: language,
    description: description,
    isDefault: isDefault,
    isDownloaded: isDownloaded,
    downloadedAt: downloadedAt,
    apiEndpoint: apiEndpoint,
  );

  factory BibleTranslationModel.fromJson(Map<String, dynamic> json) {
    return BibleTranslationModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      abbreviation: json['abbreviation'] as String,
      language: json['language'] as String,
      description: json['description'] as String?,
      isDefault: json['isDefault'] as bool,
      isDownloaded: json['isDownloaded'] as bool,
      downloadedAt: json['downloadedAt'] != null
          ? DateTime.parse(json['downloadedAt'] as String)
          : null,
      apiEndpoint: json['apiEndpoint'] as String?,
    );
  }

  factory BibleTranslationModel.fromDatabase(Map<String, dynamic> map) {
    return BibleTranslationModel(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      abbreviation: map['abbreviation'] as String,
      language: map['language'] as String,
      description: map['description'] as String?,
      isDefault: map['isDefault'] == 1,
      isDownloaded: map['isDownloaded'] == 1,
      downloadedAt: map['downloadedAt'] != null
          ? DateTime.parse(map['downloadedAt'] as String)
          : null,
      apiEndpoint: map['apiEndpoint'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'abbreviation': abbreviation,
    'language': language,
    'description': description,
    'isDefault': isDefault,
    'isDownloaded': isDownloaded,
    'downloadedAt': downloadedAt?.toIso8601String(),
    'apiEndpoint': apiEndpoint,
  };

  Map<String, dynamic> toDatabase() => {
    'id': id,
    'code': code,
    'name': name,
    'abbreviation': abbreviation,
    'language': language,
    'description': description,
    'isDefault': isDefault ? 1 : 0,
    'isDownloaded': isDownloaded ? 1 : 0,
    'downloadedAt': downloadedAt?.toIso8601String(),
    'apiEndpoint': apiEndpoint,
  };
}
