import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../models/media_item.dart';
import 'storage_service.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isFlashOn = false;
  int _currentCameraIndex = 0;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isFlashOn => _isFlashOn;
  bool get hasMultipleCameras => (_cameras?.length ?? 0) > 1;

  // Inicializar cámaras
  Future<bool> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        return false;
      }

      await _initializeCamera(_currentCameraIndex);
      return true;
    } catch (e) {
      print('Error initializing cameras: $e');
      return false;
    }
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    if (_cameras == null || _cameras!.isEmpty) return;

    // Disponer del controlador anterior si existe
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      _cameras![cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing camera controller: $e');
      _isInitialized = false;
    }
  }

  // Cambiar entre cámaras frontal y trasera
  Future<void> switchCamera() async {
    if (!hasMultipleCameras) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    await _initializeCamera(_currentCameraIndex);
  }

  // Alternar flash
  Future<void> toggleFlash() async {
    if (!_isInitialized || _controller == null) return;

    try {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    } catch (e) {
      print('Error toggling flash: $e');
      _isFlashOn = false;
    }
  }

  // Tomar foto
  Future<MediaItem?> takePicture() async {
    if (!_isInitialized || _controller == null) return null;

    try {
      // Asegurar que el flash esté configurado correctamente
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.auto);
      }

      final XFile image = await _controller!.takePicture();
      
      // Generar nombre único para la foto
      final uuid = const Uuid();
      final photoId = uuid.v4();
      final timestamp = DateTime.now();
      final fileName = 'photo_${timestamp.millisecondsSinceEpoch}.jpg';

      // Obtener directorio de fotos
      final photosDir = await StorageService().getPhotosDirectory();
      final photoPath = path.join(photosDir.path, fileName);

      // Copiar archivo a directorio de la app
      final File photoFile = File(image.path);
      await photoFile.copy(photoPath);

      // Obtener información del archivo
      final fileStat = await File(photoPath).stat();
      final fileSize = fileStat.size.toDouble();

      // Crear MediaItem
      final mediaItem = MediaItem(
        id: photoId,
        path: photoPath,
        name: fileName,
        type: MediaType.photo,
        createdAt: timestamp,
        fileSize: fileSize,
        metadata: {
          'camera': _cameras![_currentCameraIndex].name,
          'flash': _isFlashOn,
          'resolution': 'high',
        },
      );

      // Guardar en base de datos
      await StorageService().insertMediaItem(mediaItem);

      // Limpiar archivo temporal
      try {
        await File(image.path).delete();
      } catch (e) {
        print('Error deleting temp file: $e');
      }

      return mediaItem;
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  // Tomar foto con temporizador
  Future<MediaItem?> takePictureWithTimer(int seconds) async {
    if (!_isInitialized) return null;

    // Esperar el tiempo del temporizador
    await Future.delayed(Duration(seconds: seconds));
    
    return await takePicture();
  }

  // Obtener preview ratio
  double? getPreviewAspectRatio() {
    if (!_isInitialized || _controller == null) return null;
    return _controller!.value.aspectRatio;
  }

  // Verificar si la cámara está disponible
  bool get isCameraAvailable => _cameras != null && _cameras!.isNotEmpty;

  // Obtener información de la cámara actual
  CameraDescription? get currentCamera {
    if (_cameras == null || _currentCameraIndex >= _cameras!.length) {
      return null;
    }
    return _cameras![_currentCameraIndex];
  }

  // Obtener dirección de la cámara
  CameraLensDirection get currentCameraDirection {
    return currentCamera?.lensDirection ?? CameraLensDirection.back;
  }

  // Limpiar recursos
  Future<void> dispose() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    _isInitialized = false;
  }

  // Configurar resolución de la cámara
  Future<void> setResolution(ResolutionPreset resolution) async {
    if (_cameras == null || _cameras!.isEmpty) return;

    await dispose();
    
    _controller = CameraController(
      _cameras![_currentCameraIndex],
      resolution,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      print('Error setting camera resolution: $e');
      _isInitialized = false;
    }
  }
}