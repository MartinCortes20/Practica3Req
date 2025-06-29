import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // Verificar si tenemos todos los permisos necesarios
  Future<bool> hasAllPermissions() async {
    final cameraPermission = await Permission.camera.status;
    final microphonePermission = await Permission.microphone.status;
    final storagePermission = await Permission.storage.status;

    return cameraPermission.isGranted &&
        microphonePermission.isGranted &&
        storagePermission.isGranted;
  }

  // Solicitar permisos de cámara
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Solicitar permisos de micrófono
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Solicitar permisos de almacenamiento
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  // Solicitar todos los permisos necesarios
  Future<Map<String, bool>> requestAllPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();

    return {
      'camera': statuses[Permission.camera]?.isGranted ?? false,
      'microphone': statuses[Permission.microphone]?.isGranted ?? false,
      'storage': statuses[Permission.storage]?.isGranted ?? false,
    };
  }

  // Verificar permiso específico
  Future<bool> checkPermission(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  // Verificar si un permiso fue denegado permanentemente
  Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  // Abrir configuración de la app si es necesario
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}