import 'package:flutter/material.dart';

class CameraControls extends StatelessWidget {
  final VoidCallback onTakePicture;
  final VoidCallback onToggleFlash;
  final VoidCallback? onSwitchCamera;
  final bool isFlashOn;
  final bool isTimerActive;
  final VoidCallback onCancelTimer;

  const CameraControls({
    super.key,
    required this.onTakePicture,
    required this.onToggleFlash,
    this.onSwitchCamera,
    required this.isFlashOn,
    required this.isTimerActive,
    required this.onCancelTimer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black54,
            Colors.black87,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botón de flash
          _buildControlButton(
            icon: isFlashOn ? Icons.flash_on : Icons.flash_off,
            onPressed: onToggleFlash,
            isActive: isFlashOn,
          ),
          
          // Botón de captura principal
          GestureDetector(
            onTap: isTimerActive ? onCancelTimer : onTakePicture,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                color: isTimerActive ? Colors.red : Colors.transparent,
              ),
              child: isTimerActive
                  ? const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    )
                  : Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          
          // Botón de cambiar cámara
          _buildControlButton(
            icon: Icons.flip_camera_ios,
            onPressed: onSwitchCamera,
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    VoidCallback? onPressed,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.white24 : Colors.transparent,
          border: Border.all(
            color: Colors.white54,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: onPressed != null ? Colors.white : Colors.white38,
          size: 24,
        ),
      ),
    );
  }
}