import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class AudioRecorderWidget extends StatefulWidget {
  final VoidCallback? onRecordingComplete;

  const AudioRecorderWidget({
    super.key,
    this.onRecordingComplete,
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // Controlar animaciones basándose en el estado de grabación
        if (provider.isRecording) {
          _pulseController.repeat(reverse: true);
          _waveController.repeat();
        } else {
          _pulseController.stop();
          _waveController.stop();
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).primaryColor.withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              Text(
                provider.isRecording ? 'Grabando...' : 'Listo para grabar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              // Visualización central
              _buildRecordingVisualization(context, provider),
              
              const SizedBox(height: 32),
              
              // Tiempo de grabación
              _buildRecordingTime(context, provider),
              
              const SizedBox(height: 32),
              
              // Controles
              _buildControls(context, provider),
              
              const SizedBox(height: 16),
              
              // Configuraciones
              if (!provider.isRecording) _buildSettings(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecordingVisualization(BuildContext context, AppProvider provider) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ondas de fondo (solo cuando está grabando)
        if (provider.isRecording) ...[
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return Container(
                width: 200 + (_waveAnimation.value * 50),
                height: 200 + (_waveAnimation.value * 50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(
                      0.3 - (_waveAnimation.value * 0.3),
                    ),
                    width: 2,
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return Container(
                width: 160 + (_waveAnimation.value * 30),
                height: 160 + (_waveAnimation.value * 30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(
                      0.5 - (_waveAnimation.value * 0.5),
                    ),
                    width: 2,
                  ),
                ),
              );
            },
          ),
        ],
        
        // Botón central animado
        AnimatedBuilder(
          animation: provider.isRecording ? _pulseAnimation : 
                     const AlwaysStoppedAnimation(1.0),
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: provider.isRecording
                        ? [Colors.red, Colors.red.shade700]
                        : [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (provider.isRecording ? Colors.red : Theme.of(context).primaryColor)
                          .withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  provider.isRecording ? Icons.stop : Icons.mic,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecordingTime(BuildContext context, AppProvider provider) {
    if (!provider.isRecording) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(provider.recordingDuration),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, AppProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Botón de cancelar (solo cuando está grabando)
        if (provider.isRecording)
          _buildControlButton(
            icon: Icons.close,
            label: 'Cancelar',
            onPressed: () async {
              await provider.audioService.cancelRecording();
              if (mounted) Navigator.pop(context);
            },
            color: Colors.grey,
          ),
        
        // Botón principal
        _buildControlButton(
          icon: provider.isRecording ? Icons.stop : Icons.fiber_manual_record,
          label: provider.isRecording ? 'Detener' : 'Grabar',
          onPressed: () => _handleMainAction(provider),
          color: provider.isRecording ? Colors.red : Theme.of(context).primaryColor,
          isPrimary: true,
        ),
        
        // Botón de cerrar (solo cuando NO está grabando)
        if (!provider.isRecording)
          _buildControlButton(
            icon: Icons.close,
            label: 'Cerrar',
            onPressed: () => Navigator.pop(context),
            color: Colors.grey,
          ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        Container(
          width: isPrimary ? 60 : 50,
          height: isPrimary ? 60 : 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(isPrimary ? 30 : 25),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: isPrimary ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              size: isPrimary ? 28 : 24,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSettings(BuildContext context, AppProvider provider) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Text(
          'Configuración',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Sensibilidad del micrófono
        ListTile(
          leading: const Icon(Icons.mic_external_on),
          title: const Text('Sensibilidad del micrófono'),
          subtitle: Slider(
            value: provider.settings.audioSensitivity,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            label: '${(provider.settings.audioSensitivity * 100).round()}%',
            onChanged: (value) {
              final newSettings = provider.settings.copyWith(
                audioSensitivity: value,
              );
              provider.updateSettings(newSettings);
            },
          ),
        ),
        
        // Guardar automáticamente
        SwitchListTile(
          secondary: const Icon(Icons.save),
          title: const Text('Guardar automáticamente'),
          subtitle: const Text('Guardar grabaciones en la galería'),
          value: provider.settings.autoSaveAudio,
          onChanged: (value) {
            final newSettings = provider.settings.copyWith(
              autoSaveAudio: value,
            );
            provider.updateSettings(newSettings);
          },
        ),
      ],
    );
  }

  void _handleMainAction(AppProvider provider) async {
    if (provider.isRecording) {
      // Detener grabación
      await provider.stopRecording();
      widget.onRecordingComplete?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grabación guardada'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      // Iniciar grabación
      await provider.startRecording();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}