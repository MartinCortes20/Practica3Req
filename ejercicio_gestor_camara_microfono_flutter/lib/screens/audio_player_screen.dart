import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../providers/app_provider.dart';

class AudioPlayerScreen extends StatefulWidget {
  final MediaItem audioItem;

  const AudioPlayerScreen({
    super.key,
    required this.audioItem,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlayer();
    });
  }

  void _initializePlayer() {
    final provider = context.read<AppProvider>();
    if (provider.currentPlayingAudio != widget.audioItem.path) {
      provider.playAudio(widget.audioItem);
    }
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reproductor de Audio'),
        elevation: 0,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Spacer(),
                  _buildAudioInfo(context),
                  const SizedBox(height: 32),
                  _buildAudioVisualization(context),
                  const SizedBox(height: 32),
                  _buildProgressBar(context, provider),
                  const SizedBox(height: 24),
                  _buildTimeDisplay(context, provider),
                  const SizedBox(height: 32),
                  _buildPlaybackControls(context, provider),
                  const Spacer(),
                  _buildBottomControls(context, provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAudioInfo(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.audiotrack,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          widget.audioItem.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.audioItem.getFormattedSize()} • ${_formatDate(widget.audioItem.createdAt)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioVisualization(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(20, (index) {
              final isActive = provider.isPlayingAudio && 
                               provider.currentPlayingAudio == widget.audioItem.path;
              final height = isActive 
                  ? 20.0 + (index % 3) * 15.0 
                  : 10.0 + (index % 2) * 5.0;
              
              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 50)),
                width: 3,
                height: height,
                decoration: BoxDecoration(
                  color: isActive 
                      ? Theme.of(context).primaryColor
                      : Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, AppProvider provider) {
    final duration = provider.playbackDuration;
    final position = provider.playbackPosition;
    
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: duration.inMilliseconds > 0 
                ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
                : 0.0,
            onChanged: (value) {
              final newPosition = Duration(
                milliseconds: (duration.inMilliseconds * value).round(),
              );
              provider.audioService.seekAudio(newPosition);
            },
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDisplay(BuildContext context, AppProvider provider) {
    final duration = provider.playbackDuration;
    final position = provider.playbackPosition;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _formatDuration(position),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          _formatDuration(duration),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(BuildContext context, AppProvider provider) {
    final isPlaying = provider.isPlayingAudio && 
                     provider.currentPlayingAudio == widget.audioItem.path;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          icon: Icons.replay_10,
          onPressed: () => _seekRelative(provider, -10),
        ),
        const SizedBox(width: 24),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => _togglePlayback(provider),
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 24),
        _buildControlButton(
          icon: Icons.forward_10,
          onPressed: () => _seekRelative(provider, 10),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, AppProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => _showSpeedDialog(context, provider),
          icon: const Icon(Icons.speed),
          tooltip: 'Velocidad de reproducción',
        ),
        IconButton(
          onPressed: () => _shareAudio(),
          icon: const Icon(Icons.share),
          tooltip: 'Compartir',
        ),
        IconButton(
          onPressed: () => _showDeleteDialog(context, provider),
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: 'Eliminar',
        ),
        IconButton(
          onPressed: () => _showInfoDialog(context),
          icon: const Icon(Icons.info),
          tooltip: 'Información',
        ),
      ],
    );
  }

  void _togglePlayback(AppProvider provider) {
    if (provider.isPlayingAudio && provider.currentPlayingAudio == widget.audioItem.path) {
      provider.audioService.pauseAudio();
    } else {
      provider.playAudio(widget.audioItem);
    }
  }

  void _seekRelative(AppProvider provider, int seconds) {
    final currentPosition = provider.playbackPosition;
    final newPosition = Duration(
      milliseconds: currentPosition.inMilliseconds + (seconds * 1000),
    );
    provider.audioService.seekAudio(newPosition);
  }

  void _showSpeedDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Velocidad de reproducción'),
        content: const Text('Función no implementada'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _shareAudio() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de compartir no implementada')),
    );
  }

  void _showDeleteDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar audio'),
        content: Text('¿Estás seguro de que quieres eliminar "${widget.audioItem.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              provider.deleteMediaItem(widget.audioItem);
              Navigator.pop(context); // Volver a la galería
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información del audio'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow('Nombre:', widget.audioItem.name),
            _buildInfoRow('Tamaño:', widget.audioItem.getFormattedSize()),
            _buildInfoRow('Duración:', widget.audioItem.getFormattedDuration()),
            _buildInfoRow('Fecha:', _formatDate(widget.audioItem.createdAt)),
            _buildInfoRow('Formato:', 'M4A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}