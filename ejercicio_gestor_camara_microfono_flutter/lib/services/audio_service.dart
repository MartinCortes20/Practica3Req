import 'dart:io';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../models/media_item.dart';
import 'storage_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentRecordingPath;
  String? _currentPlayingPath;
  DateTime? _recordingStartTime;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get currentPlayingPath => _currentPlayingPath;

  // Inicializar servicio de audio
  Future<bool> initialize() async {
    try {
      // Verificar si tenemos permisos de micrófono
      bool hasPermission = await _recorder.hasPermission();
      return hasPermission;
    } catch (e) {
      print('Error initializing audio service: $e');
      return false;
    }
  }

  // Iniciar grabación
  Future<bool> startRecording({double sensitivity = 0.5}) async {
    if (_isRecording) return false;

    try {
      // Generar nombre único para el audio
      final timestamp = DateTime.now();
      final fileName = 'audio_${timestamp.millisecondsSinceEpoch}.m4a';
      
      // Obtener directorio de audio
      final audioDir = await StorageService().getAudioDirectory();
      final audioPath = path.join(audioDir.path, fileName);

      // Configurar grabación
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );

      // Iniciar grabación
      await _recorder.start(config, path: audioPath);
      
      _isRecording = true;
      _currentRecordingPath = audioPath;
      _recordingStartTime = timestamp;
      
      return true;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
    }
  }

  // Detener grabación
  Future<MediaItem?> stopRecording() async {
    if (!_isRecording || _currentRecordingPath == null) return null;

    try {
      final recordingPath = await _recorder.stop();
      _isRecording = false;

      if (recordingPath == null || _recordingStartTime == null) return null;

      // Calcular duración
      final endTime = DateTime.now();
      final duration = endTime.difference(_recordingStartTime!).inSeconds;

      // Obtener información del archivo
      final audioFile = File(_currentRecordingPath!);
      final fileStat = await audioFile.stat();
      final fileSize = fileStat.size.toDouble();

      // Generar ID único
      final uuid = const Uuid();
      final audioId = uuid.v4();
      final fileName = path.basename(_currentRecordingPath!);

      // Crear MediaItem
      final mediaItem = MediaItem(
        id: audioId,
        path: _currentRecordingPath!,
        name: fileName,
        type: MediaType.audio,
        createdAt: _recordingStartTime!,
        duration: duration,
        fileSize: fileSize,
        metadata: {
          'format': 'm4a',
          'bitRate': 128,
          'sampleRate': 44100,
        },
      );

      // Guardar en base de datos
      await StorageService().insertMediaItem(mediaItem);

      // Limpiar variables
      _currentRecordingPath = null;
      _recordingStartTime = null;

      return mediaItem;
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      _currentRecordingPath = null;
      _recordingStartTime = null;
      return null;
    }
  }

  // Reproducir audio
  Future<bool> playAudio(String audioPath) async {
    if (_isPlaying) {
      await stopAudio();
    }

    try {
      await _player.play(DeviceFileSource(audioPath));
      _isPlaying = true;
      _currentPlayingPath = audioPath;

      // Escuchar cuando termine la reproducción
      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
        _currentPlayingPath = null;
      });

      return true;
    } catch (e) {
      print('Error playing audio: $e');
      return false;
    }
  }

  // Pausar audio
  Future<void> pauseAudio() async {
    if (_isPlaying) {
      await _player.pause();
      _isPlaying = false;
    }
  }

  // Reanudar audio
  Future<void> resumeAudio() async {
    if (!_isPlaying && _currentPlayingPath != null) {
      await _player.resume();
      _isPlaying = true;
    }
  }

  // Detener audio
  Future<void> stopAudio() async {
    await _player.stop();
    _isPlaying = false;
    _currentPlayingPath = null;
  }

  // Obtener duración del audio actual
  Future<Duration?> getCurrentDuration() async {
    return await _player.getDuration();
  }

  // Obtener posición actual del audio
  Future<Duration?> getCurrentPosition() async {
    return await _player.getCurrentPosition();
  }

  // Buscar posición en el audio
  Future<void> seekAudio(Duration position) async {
    await _player.seek(position);
  }

  // Configurar volumen
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  // Obtener stream de posición para UI
  Stream<Duration> get positionStream => _player.onPositionChanged;

  // Obtener stream de duración para UI
  Stream<Duration> get durationStream => _player.onDurationChanged;

  // Verificar si un archivo de audio existe
  Future<bool> audioFileExists(String path) async {
    final file = File(path);
    return await file.exists();
  }

  // Obtener información del audio
  Future<Map<String, dynamic>?> getAudioInfo(String audioPath) async {
    try {
      final file = File(audioPath);
      if (!await file.exists()) return null;

      final stat = await file.stat();
      
      return {
        'size': stat.size,
        'modified': stat.modified,
        'path': audioPath,
      };
    } catch (e) {
      print('Error getting audio info: $e');
      return null;
    }
  }

  // Limpiar recursos
  Future<void> dispose() async {
    await stopAudio();
    await _recorder.dispose();
    await _player.dispose();
  }

  // Cancelar grabación actual
  Future<void> cancelRecording() async {
    if (_isRecording) {
      await _recorder.stop();
      _isRecording = false;
      
      // Eliminar archivo temporal si existe
      if (_currentRecordingPath != null) {
        try {
          final file = File(_currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Error deleting cancelled recording: $e');
        }
      }
      
      _currentRecordingPath = null;
      _recordingStartTime = null;
    }
  }
}