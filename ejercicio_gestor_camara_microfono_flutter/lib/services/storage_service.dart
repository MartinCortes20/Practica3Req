import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/media_item.dart';
import '../models/app_settings.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Database? _database;
  SharedPreferences? _prefs;

  // Inicializar base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = path.join(documentsDirectory.path, 'media_app.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE media_items(
            id TEXT PRIMARY KEY,
            path TEXT NOT NULL,
            name TEXT NOT NULL,
            type INTEGER NOT NULL,
            createdAt INTEGER NOT NULL,
            duration INTEGER,
            fileSize REAL,
            metadata TEXT
          )
          ''',
        );
      },
    );
  }

  // Inicializar SharedPreferences
  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  // CRUD para MediaItems
  Future<void> insertMediaItem(MediaItem item) async {
    final db = await database;
    await db.insert(
      'media_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MediaItem>> getAllMediaItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'media_items',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return MediaItem.fromMap(maps[i]);
    });
  }

  Future<List<MediaItem>> getMediaItemsByType(MediaType type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'media_items',
      where: 'type = ?',
      whereArgs: [type.index],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return MediaItem.fromMap(maps[i]);
    });
  }

  Future<void> deleteMediaItem(String id) async {
    final db = await database;
    await db.delete(
      'media_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateMediaItem(MediaItem item) async {
    final db = await database;
    await db.update(
      'media_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Gestión de configuraciones
  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await this.prefs;
    final settingsMap = settings.toMap();
    
    for (final entry in settingsMap.entries) {
      if (entry.value is bool) {
        await prefs.setBool(entry.key, entry.value as bool);
      } else if (entry.value is int) {
        await prefs.setInt(entry.key, entry.value as int);
      } else if (entry.value is double) {
        await prefs.setDouble(entry.key, entry.value as double);
      } else if (entry.value is String) {
        await prefs.setString(entry.key, entry.value as String);
      }
    }
  }

  Future<AppSettings> loadSettings() async {
    final prefs = await this.prefs;
    
    final Map<String, dynamic> settingsMap = {
      'themeType': prefs.getInt('themeType') ?? 0,
      'isDarkMode': prefs.getBool('isDarkMode') ?? false,
      'autoSavePhotos': prefs.getBool('autoSavePhotos') ?? true,
      'autoSaveAudio': prefs.getBool('autoSaveAudio') ?? true,
      'photoQuality': prefs.getString('photoQuality') ?? 'high',
      'audioQuality': prefs.getInt('audioQuality') ?? 128,
      'enableFlash': prefs.getBool('enableFlash') ?? false,
      'enableTimer': prefs.getBool('enableTimer') ?? false,
      'timerDuration': prefs.getInt('timerDuration') ?? 3,
      'audioSensitivity': prefs.getDouble('audioSensitivity') ?? 0.5,
      'enableLocationTags': prefs.getBool('enableLocationTags') ?? false,
    };

    return AppSettings.fromMap(settingsMap);
  }

  // Gestión de directorios
  Future<Directory> getAppDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return appDir;
  }

  Future<Directory> getPhotosDirectory() async {
    final appDir = await getAppDirectory();
    final photosDir = Directory(path.join(appDir.path, 'photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    return photosDir;
  }

  Future<Directory> getAudioDirectory() async {
    final appDir = await getAppDirectory();
    final audioDir = Directory(path.join(appDir.path, 'audio'));
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  // Limpiar archivos huérfanos
  Future<void> cleanupOrphanedFiles() async {
    final mediaItems = await getAllMediaItems();
    final existingPaths = mediaItems.map((item) => item.path).toSet();

    final photosDir = await getPhotosDirectory();
    final audioDir = await getAudioDirectory();

    // Limpiar fotos huérfanas
    await _cleanupDirectory(photosDir, existingPaths);
    
    // Limpiar audios huérfanos
    await _cleanupDirectory(audioDir, existingPaths);
  }

  Future<void> _cleanupDirectory(Directory dir, Set<String> existingPaths) async {
    if (!await dir.exists()) return;

    final files = await dir.list().toList();
    for (final file in files) {
      if (file is File && !existingPaths.contains(file.path)) {
        try {
          await file.delete();
        } catch (e) {
          print('Error deleting orphaned file: ${file.path}');
        }
      }
    }
  }
}