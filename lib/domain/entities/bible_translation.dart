import 'package:equatable/equatable.dart';

class BibleTranslation extends Equatable {
  final String id;
  final String code; // 'KJV', 'NIV', 'ESV', etc.
  final String name; // 'King James Version'
  final String abbreviation;
  final String language;
  final String? description;
  final bool isDefault;
  final bool isDownloaded;
  final DateTime? downloadedAt;
  final String? apiEndpoint;

  const BibleTranslation({
    required this.id,
    required this.code,
    required this.name,
    required this.abbreviation,
    required this.language,
    this.description,
    required this.isDefault,
    required this.isDownloaded,
    this.downloadedAt,
    this.apiEndpoint,
  });

  BibleTranslation copyWith({
    String? id,
    String? code,
    String? name,
    String? abbreviation,
    String? language,
    String? description,
    bool? isDefault,
    bool? isDownloaded,
    DateTime? downloadedAt,
    String? apiEndpoint,
  }) {
    return BibleTranslation(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      language: language ?? this.language,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
    );
  }

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    abbreviation,
    language,
    description,
    isDefault,
    isDownloaded,
    downloadedAt,
    apiEndpoint,
  ];
}
