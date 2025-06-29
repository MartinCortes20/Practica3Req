import 'dart:io'; // AGREGAR ESTA LÍNEA
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/media_item.dart';
import '../themes/app_themes.dart';
import '../services/camera_service.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../services/permission_service.dart';

class AppProvider with ChangeNotifier {
  // Servicios
  final CameraService _cameraService = CameraService();
  final AudioService _audioService = AudioService();
  final StorageService _storageService = StorageService();
  final PermissionService _permissionService = PermissionService();

  // Estado de la aplicación
  AppSettings _settings = AppSettings();
  List<MediaItem> _mediaItems = [];
  List<MediaItem> _photos = [];
  List<MediaItem> _audioRecordings = [];
  bool _isLoading = false;
  bool _hasPermissions = false;
  String? _errorMessage;

  // Estado de cámara
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isTimerActive = false;
  int _timerCountdown = 0;

  // Estado de audio
  bool _isRecording = false;
  bool _isPlayingAudio = false;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  Duration _playbackDuration = Duration.zero;
  String? _currentPlayingAudio;

  // Getters
  AppSettings get settings => _settings;
  List<MediaItem> get mediaItems => _mediaItems;
  List<MediaItem> get photos => _photos;
  List<MediaItem> get audioRecordings => _audioRecordings;
  bool get isLoading => _isLoading;
  bool get hasPermissions => _hasPermissions;
  String? get errorMessage => _errorMessage;

  // Getters de cámara
  bool get isCameraInitialized => _isCameraInitialized;
  bool get isFlashOn => _isFlashOn;
  bool get isTimerActive => _isTimerActive;
  int get timerCountdown => _timerCountdown;
  CameraService get cameraService => _cameraService;

  // Getters de audio
  bool get isRecording => _isRecording;
  bool get isPlayingAudio => _isPlayingAudio;
  Duration get recordingDuration => _recordingDuration;
  Duration get playbackPosition => _playbackPosition;
  Duration get playbackDuration => _playbackDuration;
  String? get currentPlayingAudio => _currentPlayingAudio;
  AudioService get audioService => _audioService;

  // Tema actual
  ThemeData get currentTheme => AppThemes.getTheme(_settings.themeType, _settings.isDarkMode);

  // Inicializar aplicación
  Future<void> initialize() async {
    setLoading(true);
    
    try {
      // Cargar configuraciones
      _settings = await _storageService.loadSettings();
      
      // Verificar permisos
      _hasPermissions = await _permissionService.hasAllPermissions();
      
      if (_hasPermissions) {
        // Inicializar servicios
        await _initializeServices();
        
        // Cargar elementos multimedia
        await loadMediaItems();
      }
      
      clearError();
    } catch (e) {
      setError('Error inicializando la aplicación: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> _initializeServices() async {
    // Inicializar cámara
    _isCameraInitialized = await _cameraService.initialize();
    
    // Inicializar audio
    await _audioService.initialize();
    
    // Configurar flash según configuración
    if (_settings.enableFlash) {
      await toggleFlash();
    }
  }

  // Gestión de permisos
  Future<bool> requestPermissions() async {
    setLoading(true);
    
    try {
      final permissions = await _permissionService.requestAllPermissions();
      _hasPermissions = permissions.values.every((granted) => granted);
      
      if (_hasPermissions) {
        await _initializeServices();
        await loadMediaItems();
      }
      
      notifyListeners();
      return _hasPermissions;
    } catch (e) {
      setError('Error solicitando permisos: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Gestión de configuraciones
  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> changeTheme(AppThemeType themeType) async {
    final newSettings = _settings.copyWith(themeType: themeType);
    await updateSettings(newSettings);
  }

  Future<void> toggleDarkMode() async {
    final newSettings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    await updateSettings(newSettings);
  }

  // Gestión de elementos multimedia
  Future<void> loadMediaItems() async {
    try {
      _mediaItems = await _storageService.getAllMediaItems();
      _photos = await _storageService.getMediaItemsByType(MediaType.photo);
      _audioRecordings = await _storageService.getMediaItemsByType(MediaType.audio);
      notifyListeners();
    } catch (e) {
      setError('Error cargando elementos multimedia: $e');
    }
  }

  Future<void> deleteMediaItem(MediaItem item) async {
    try {
      // Eliminar archivo físico
      final file = File(item.path);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Eliminar de base de datos
      await _storageService.deleteMediaItem(item.id);
      
      // Actualizar listas
      await loadMediaItems();
      
    } catch (e) {
      setError('Error eliminando elemento: $e');
    }
  }

  // Funciones de cámara
  Future<void> initializeCamera() async {
    if (!_hasPermissions) return;
    
    try {
      _isCameraInitialized = await _cameraService.initialize();
      notifyListeners();
    } catch (e) {
      setError('Error inicializando cámara: $e');
    }
  }

  Future<void> switchCamera() async {
    if (!_isCameraInitialized) return;
    
    try {
      await _cameraService.switchCamera();
      notifyListeners();
    } catch (e) {
      setError('Error cambiando cámara: $e');
    }
  }

  Future<void> toggleFlash() async {
    if (!_isCameraInitialized) return;
    
    try {
      await _cameraService.toggleFlash();
      _isFlashOn = _cameraService.isFlashOn;
      
      // Actualizar configuración
      final newSettings = _settings.copyWith(enableFlash: _isFlashOn);
      await updateSettings(newSettings);
      
      notifyListeners();
    } catch (e) {
      setError('Error alternando flash: $e');
    }
  }

  Future<void> takePicture() async {
    if (!_isCameraInitialized) return;
    
    try {
      MediaItem? photo;
      
      if (_settings.enableTimer) {
        photo = await _takePictureWithTimer();
      } else {
        photo = await _cameraService.takePicture();
      }
      
      if (photo != null) {
        await loadMediaItems();
      }
    } catch (e) {
      setError('Error tomando foto: $e');
    }
  }

  Future<MediaItem?> _takePictureWithTimer() async {
    _isTimerActive = true;
    _timerCountdown = _settings.timerDuration;
    notifyListeners();
    
    // Countdown
    for (int i = _settings.timerDuration; i > 0; i--) {
      _timerCountdown = i;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));
    }
    
    _isTimerActive = false;
    _timerCountdown = 0;
    notifyListeners();
    
    return await _cameraService.takePicture();
  }

  void cancelTimer() {
    _isTimerActive = false;
    _timerCountdown = 0;
    notifyListeners();
  }

  // Funciones de audio
  Future<void> startRecording() async {
    if (!_hasPermissions || _isRecording) return;
    
    try {
      final success = await _audioService.startRecording(
        sensitivity: _settings.audioSensitivity,
      );
      
      if (success) {
        _isRecording = true;
        _recordingDuration = Duration.zero;
        _startRecordingTimer();
        notifyListeners();
      }
    } catch (e) {
      setError('Error iniciando grabación: $e');
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;
    
    try {
      final audioItem = await _audioService.stopRecording();
      _isRecording = false;
      _recordingDuration = Duration.zero;
      
      if (audioItem != null) {
        await loadMediaItems();
      }
      
      notifyListeners();
    } catch (e) {
      setError('Error deteniendo grabación: $e');
    }
  }

  void _startRecordingTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording) {
        _recordingDuration = Duration(seconds: _recordingDuration.inSeconds + 1);
        notifyListeners();
        _startRecordingTimer();
      }
    });
  }

  Future<void> playAudio(MediaItem audioItem) async {
    try {
      if (_currentPlayingAudio == audioItem.path && _isPlayingAudio) {
        await _audioService.pauseAudio();
        _isPlayingAudio = false;
      } else {
        if (_currentPlayingAudio != null) {
          await _audioService.stopAudio();
        }
        
        final success = await _audioService.playAudio(audioItem.path);
        if (success) {
          _currentPlayingAudio = audioItem.path;
          _isPlayingAudio = true;
          _setupAudioStreams();
        }
      }
      notifyListeners();
    } catch (e) {
      setError('Error reproduciendo audio: $e');
    }
  }

  void _setupAudioStreams() {
    _audioService.positionStream.listen((position) {
      _playbackPosition = position;
      notifyListeners();
    });
    
    _audioService.durationStream.listen((duration) {
      _playbackDuration = duration;
      notifyListeners();
    });
  }

  Future<void> stopAudio() async {
    await _audioService.stopAudio();
    _isPlayingAudio = false;
    _currentPlayingAudio = null;
    _playbackPosition = Duration.zero;
    _playbackDuration = Duration.zero;
    notifyListeners();
  }

  // Utilidades
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _audioService.dispose();
    super.dispose();
  }
}