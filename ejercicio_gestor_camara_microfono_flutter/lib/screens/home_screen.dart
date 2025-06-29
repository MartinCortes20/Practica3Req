import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../themes/app_themes.dart';
import 'camera_screen.dart';
import 'gallery_screen.dart';
import '../models/media_item.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (!provider.hasPermissions) {
          return _buildPermissionScreen(context, provider);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cámara y Micrófono'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'theme_guinda':
                      provider.changeTheme(AppThemeType.guindaIPN);
                      break;
                    case 'theme_azul':
                      provider.changeTheme(AppThemeType.azulESCOM);
                      break;
                    case 'toggle_dark':
                      provider.toggleDarkMode();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'theme_guinda',
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppThemes.guindaPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Tema Guinda (IPN)'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'theme_azul',
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppThemes.azulPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Tema Azul (ESCOM)'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_dark',
                    child: Row(
                      children: [
                        Icon(
                          provider.settings.isDarkMode 
                              ? Icons.light_mode 
                              : Icons.dark_mode,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          provider.settings.isDarkMode 
                              ? 'Modo Claro' 
                              : 'Modo Oscuro',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: _buildHomeContent(context, provider),
          bottomNavigationBar: _buildBottomNavigation(context, provider),
        );
      },
    );
  }

  Widget _buildPermissionScreen(BuildContext context, AppProvider provider) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Permisos Necesarios',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Esta aplicación necesita acceso a la cámara, micrófono y almacenamiento para funcionar correctamente.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (provider.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () => provider.requestPermissions(),
                  child: const Text('Conceder Permisos'),
                ),
              if (provider.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  provider.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estadísticas
          _buildStatsCards(context, provider),
          const SizedBox(height: 24),
          
          // Accesos rápidos
          Text(
            'Acciones Rápidas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(context, provider),
          
          const SizedBox(height: 24),
          
          // Elementos recientes
          Text(
            'Elementos Recientes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildRecentItems(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, AppProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Fotos',
            provider.photos.length.toString(),
            Icons.photo_camera,
            Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Audios',
            provider.audioRecordings.length.toString(),
            Icons.mic,
            Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            'Tomar Foto',
            Icons.camera_alt,
            () => _navigateToCamera(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            context,
            'Grabar Audio',
            Icons.mic,
            () => _showAudioRecorder(context, provider),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildRecentItems(BuildContext context, AppProvider provider) {
    if (provider.mediaItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay elementos aún',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toma fotos o graba audios para verlos aquí',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final recentItems = provider.mediaItems.take(10).toList();

    return ListView.builder(
      itemCount: recentItems.length,
      itemBuilder: (context, index) {
        final item = recentItems[index];
        return _buildMediaItemTile(context, item, provider);
      },
    );
  }

  Widget _buildMediaItemTile(BuildContext context, dynamic item, AppProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.type == MediaType.photo 
              ? Theme.of(context).primaryColor 
              : Theme.of(context).colorScheme.secondary,
          child: Icon(
            item.type == MediaType.photo ? Icons.photo : Icons.audiotrack,
            color: Colors.white,
          ),
        ),
        title: Text(item.name),
        subtitle: Text(
          '${item.getFormattedSize()} • ${_formatDate(item.createdAt)}',
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (item.type == MediaType.audio)
              PopupMenuItem(
                child: const Text('Reproducir'),
                onTap: () => provider.playAudio(item),
              ),
            PopupMenuItem(
              child: const Text('Eliminar'),
              onTap: () => _showDeleteDialog(context, item, provider),
            ),
          ],
        ),
        onTap: () {
          if (item.type == MediaType.photo) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GalleryScreen(),
              ),
            );
          } else {
            provider.playAudio(item);
          }
        },
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, AppProvider provider) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt),
          label: 'Cámara',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_library),
          label: 'Galería',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.mic),
          label: 'Audio',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Ya estamos en inicio
            break;
          case 1:
            _navigateToCamera(context);
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GalleryScreen()),
            );
            break;
          case 3:
            _showAudioRecorder(context, provider);
            break;
        }
      },
    );
  }

  void _navigateToCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
  }

  void _showAudioRecorder(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildAudioRecorderSheet(context, provider),
    );
  }

  Widget _buildAudioRecorderSheet(BuildContext context, AppProvider provider) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic,
            size: 64,
            color: provider.isRecording 
                ? Colors.red 
                : Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          if (provider.isRecording) ...[
            Text(
              'Grabando...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _formatDuration(provider.recordingDuration),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else ...[
            Text(
              'Listo para grabar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (provider.isRecording) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    provider.stopRecording();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.stop),
                  label: const Text('Detener'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: () => provider.startRecording(),
                  icon: const Icon(Icons.fiber_manual_record),
                  label: const Text('Grabar'),
                ),
              ],
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic item, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar elemento'),
        content: Text('¿Estás seguro de que quieres eliminar "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteMediaItem(item);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}