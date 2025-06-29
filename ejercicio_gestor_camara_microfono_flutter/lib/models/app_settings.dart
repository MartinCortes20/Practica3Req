import '../themes/app_themes.dart';

class AppSettings {
  final AppThemeType themeType;
  final bool isDarkMode;
  final bool autoSavePhotos;
  final bool autoSaveAudio;
  final String photoQuality;
  final int audioQuality;
  final bool enableFlash;
  final bool enableTimer;
  final int timerDuration;
  final double audioSensitivity;
  final bool enableLocationTags;

  AppSettings({
    this.themeType = AppThemeType.guindaIPN,
    this.isDarkMode = false,
    this.autoSavePhotos = true,
    this.autoSaveAudio = true,
    this.photoQuality = 'high',
    this.audioQuality = 128,
    this.enableFlash = false,
    this.enableTimer = false,
    this.timerDuration = 3,
    this.audioSensitivity = 0.5,
    this.enableLocationTags = false,
  });

  // Convertir a Map para SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'themeType': themeType.index,
      'isDarkMode': isDarkMode,
      'autoSavePhotos': autoSavePhotos,
      'autoSaveAudio': autoSaveAudio,
      'photoQuality': photoQuality,
      'audioQuality': audioQuality,
      'enableFlash': enableFlash,
      'enableTimer': enableTimer,
      'timerDuration': timerDuration,
      'audioSensitivity': audioSensitivity,
      'enableLocationTags': enableLocationTags,
    };
  }

  // Crear desde Map de SharedPreferences
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeType: AppThemeType.values[map['themeType'] ?? 0],
      isDarkMode: map['isDarkMode'] ?? false,
      autoSavePhotos: map['autoSavePhotos'] ?? true,
      autoSaveAudio: map['autoSaveAudio'] ?? true,
      photoQuality: map['photoQuality'] ?? 'high',
      audioQuality: map['audioQuality'] ?? 128,
      enableFlash: map['enableFlash'] ?? false,
      enableTimer: map['enableTimer'] ?? false,
      timerDuration: map['timerDuration'] ?? 3,
      audioSensitivity: map['audioSensitivity'] ?? 0.5,
      enableLocationTags: map['enableLocationTags'] ?? false,
    );
  }

  // Crear copia con modificaciones
  AppSettings copyWith({
    AppThemeType? themeType,
    bool? isDarkMode,
    bool? autoSavePhotos,
    bool? autoSaveAudio,
    String? photoQuality,
    int? audioQuality,
    bool? enableFlash,
    bool? enableTimer,
    int? timerDuration,
    double? audioSensitivity,
    bool? enableLocationTags,
  }) {
    return AppSettings(
      themeType: themeType ?? this.themeType,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      autoSavePhotos: autoSavePhotos ?? this.autoSavePhotos,
      autoSaveAudio: autoSaveAudio ?? this.autoSaveAudio,
      photoQuality: photoQuality ?? this.photoQuality,
      audioQuality: audioQuality ?? this.audioQuality,
      enableFlash: enableFlash ?? this.enableFlash,
      enableTimer: enableTimer ?? this.enableTimer,
      timerDuration: timerDuration ?? this.timerDuration,
      audioSensitivity: audioSensitivity ?? this.audioSensitivity,
      enableLocationTags: enableLocationTags ?? this.enableLocationTags,
    );
  }

  @override
  String toString() {
    return 'AppSettings(themeType: $themeType, isDarkMode: $isDarkMode, photoQuality: $photoQuality)';
  }
}