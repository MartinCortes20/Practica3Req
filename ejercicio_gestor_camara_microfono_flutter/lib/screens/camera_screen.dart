import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../providers/app_provider.dart';
import '../widgets/camera_controls.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      if (!provider.isCameraInitialized) {
        provider.initializeCamera();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<AppProvider>();
    if (!provider.isCameraInitialized || provider.cameraService.controller == null) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      provider.cameraService.dispose();
    } else if (state == AppLifecycleState.resumed) {
      provider.initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cámara',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                ),
                onPressed: provider.isCameraInitialized
                    ? () => provider.toggleFlash()
                    : null,
              );
            },
          ),
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(
                  Icons.flip_camera_ios,
                  color: Colors.white,
                ),
                onPressed: provider.isCameraInitialized &&
                        provider.cameraService.hasMultipleCameras
                    ? () => provider.switchCamera()
                    : null,
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.errorMessage != null) {
            return _buildErrorScreen(context, provider);
          }

          if (!provider.isCameraInitialized) {
            return _buildLoadingScreen(context);
          }

          return Stack(
            children: [
              // Vista previa de la cámara
              _buildCameraPreview(context, provider),
              
              // Overlay del temporizador
              if (provider.isTimerActive)
                _buildTimerOverlay(context, provider),
              
              // Controles de la cámara
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CameraControls(
                  onTakePicture: () => _takePicture(context, provider),
                  onToggleFlash: () => provider.toggleFlash(),
                  onSwitchCamera: provider.cameraService.hasMultipleCameras
                      ? () => provider.switchCamera()
                      : null,
                  isFlashOn: provider.isFlashOn,
                  isTimerActive: provider.isTimerActive,
                  onCancelTimer: () => provider.cancelTimer(),
                ),
              ),
              
              // Configuraciones rápidas
              Positioned(
                top: MediaQuery.of(context).padding.top + 60,
                right: 16,
                child: _buildQuickSettings(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, AppProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error de Cámara',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.initializeCamera(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Inicializando cámara...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(BuildContext context, AppProvider provider) {
    final controller = provider.cameraService.controller;
    if (controller == null) return Container();

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize?.height ?? 0,
          height: controller.value.previewSize?.width ?? 0,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildTimerOverlay(BuildContext context, AppProvider provider) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              provider.timerCountdown.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 120,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Preparándose para tomar la foto...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => provider.cancelTimer(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSettings(BuildContext context, AppProvider provider) {
    return Column(
      children: [
        _buildSettingButton(
          context,
          icon: provider.settings.enableTimer ? Icons.timer : Icons.timer_off,
          isActive: provider.settings.enableTimer,
          onTap: () => _toggleTimer(context, provider),
        ),
        const SizedBox(height: 12),
        _buildSettingButton(
          context,
          icon: Icons.settings,
          isActive: false,
          onTap: () => _showCameraSettings(context, provider),
        ),
      ],
    );
  }

  Widget _buildSettingButton(
    BuildContext context, {
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).primaryColor : Colors.black54,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white24,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _takePicture(BuildContext context, AppProvider provider) async {
    if (provider.isTimerActive) return;

    try {
      await provider.takePicture();
      
      // Mostrar feedback visual
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto guardada'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleTimer(BuildContext context, AppProvider provider) {
    final newSettings = provider.settings.copyWith(
      enableTimer: !provider.settings.enableTimer,
    );
    provider.updateSettings(newSettings);
  }

  void _showCameraSettings(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSettingsSheet(context, provider),
    );
  }

  Widget _buildSettingsSheet(BuildContext context, AppProvider provider) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración de Cámara',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Temporizador
          SwitchListTile(
            title: const Text('Temporizador'),
            subtitle: Text(
              provider.settings.enableTimer
                  ? '${provider.settings.timerDuration} segundos'
                  : 'Desactivado',
            ),
            value: provider.settings.enableTimer,
            onChanged: (value) {
              final newSettings = provider.settings.copyWith(enableTimer: value);
              provider.updateSettings(newSettings);
            },
          ),
          
          // Duración del temporizador
          if (provider.settings.enableTimer) ...[
            ListTile(
              title: const Text('Duración del temporizador'),
              subtitle: Slider(
                value: provider.settings.timerDuration.toDouble(),
                min: 3,
                max: 10,
                divisions: 7,
                label: '${provider.settings.timerDuration}s',
                onChanged: (value) {
                  final newSettings = provider.settings.copyWith(
                    timerDuration: value.round(),
                  );
                  provider.updateSettings(newSettings);
                },
              ),
            ),
          ],
          
          // Guardar automáticamente
          SwitchListTile(
            title: const Text('Guardar fotos automáticamente'),
            subtitle: const Text('Guardar en la galería del dispositivo'),
            value: provider.settings.autoSavePhotos,
            onChanged: (value) {
              final newSettings = provider.settings.copyWith(autoSavePhotos: value);
              provider.updateSettings(newSettings);
            },
          ),
        ],
      ),
    );
  }
}