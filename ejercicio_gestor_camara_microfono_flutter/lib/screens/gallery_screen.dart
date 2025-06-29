import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/media_item.dart';
import '../widgets/media_grid_item.dart';
import 'audio_player_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadMediaItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galería'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todo', icon: Icon(Icons.all_inclusive)),
            Tab(text: 'Fotos', icon: Icon(Icons.photo)),
            Tab(text: 'Audio', icon: Icon(Icons.audiotrack)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete_all':
                  _showDeleteAllDialog(context);
                  break;
                case 'sort_date':
                  _sortByDate();
                  break;
                case 'sort_name':
                  _sortByName();
                  break;
                case 'sort_size':
                  _sortBySize();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort_date',
                child: Row(
                  children: [
                    Icon(Icons.date_range),
                    SizedBox(width: 8),
                    Text('Ordenar por fecha'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sort_name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 8),
                    Text('Ordenar por nombre'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sort_size',
                child: Row(
                  children: [
                    Icon(Icons.storage),
                    SizedBox(width: 8),
                    Text('Ordenar por tamaño'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar todo', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildMediaGrid(context, provider.mediaItems, provider),
              _buildMediaGrid(context, provider.photos, provider),
              _buildAudioList(context, provider.audioRecordings, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context, List<MediaItem> items, AppProvider provider) {
    if (items.isEmpty) {
      return _buildEmptyState(context, _getEmptyStateInfo());
    }

    if (_isGridView) {
      return _buildGridView(context, items, provider);
    } else {
      return _buildListView(context, items, provider);
    }
  }

  Widget _buildGridView(BuildContext context, List<MediaItem> items, AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return MediaGridItem(
            mediaItem: item,
            onTap: () => _openMediaItem(context, item, provider),
            onLongPress: () => _showItemOptions(context, item, provider),
          );
        },
      ),
    );
  }

  Widget _buildListView(BuildContext context, List<MediaItem> items, AppProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: _buildItemThumbnail(item),
            title: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${item.getFormattedSize()} • ${_formatDate(item.createdAt)}',
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                if (item.type == MediaType.audio)
                  PopupMenuItem(
                    child: const Text('Reproducir'),
                    onTap: () => _playAudioItem(context, item, provider),
                  ),
                PopupMenuItem(
                  child: const Text('Compartir'),
                  onTap: () => _shareItem(item),
                ),
                PopupMenuItem(
                  child: const Text('Eliminar'),
                  onTap: () => _deleteItem(context, item, provider),
                ),
              ],
            ),
            onTap: () => _openMediaItem(context, item, provider),
          ),
        );
      },
    );
  }

  Widget _buildAudioList(BuildContext context, List<MediaItem> audioItems, AppProvider provider) {
    if (audioItems.isEmpty) {
      return _buildEmptyState(context, {
        'icon': Icons.audiotrack,
        'title': 'No hay grabaciones de audio',
        'subtitle': 'Graba tu primer audio para verlo aquí',
      });
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: audioItems.length,
      itemBuilder: (context, index) {
        final item = audioItems[index];
        final isPlaying = provider.currentPlayingAudio == item.path && provider.isPlayingAudio;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
            title: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.getFormattedSize()} • ${item.getFormattedDuration()}'),
                Text(_formatDate(item.createdAt)),
                if (isPlaying) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: provider.playbackDuration.inMilliseconds > 0
                        ? provider.playbackPosition.inMilliseconds / provider.playbackDuration.inMilliseconds
                        : 0,
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Abrir reproductor'),
                  onTap: () => _openAudioPlayer(context, item),
                ),
                PopupMenuItem(
                  child: const Text('Compartir'),
                  onTap: () => _shareItem(item),
                ),
                PopupMenuItem(
                  child: const Text('Eliminar'),
                  onTap: () => _deleteItem(context, item, provider),
                ),
              ],
            ),
            onTap: () => _playAudioItem(context, item, provider),
          ),
        );
      },
    );
  }

  Widget _buildItemThumbnail(MediaItem item) {
    if (item.type == MediaType.photo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(item.path),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 56,
              height: 56,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image),
            );
          },
        ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.audiotrack, color: Colors.white),
      );
    }
  }

  Widget _buildEmptyState(BuildContext context, Map<String, dynamic> info) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              info['icon'] as IconData,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              info['title'] as String,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              info['subtitle'] as String,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getEmptyStateInfo() {
    switch (_tabController.index) {
      case 1:
        return {
          'icon': Icons.photo_camera,
          'title': 'No hay fotos',
          'subtitle': 'Toma tu primera foto para verla aquí',
        };
      case 2:
        return {
          'icon': Icons.audiotrack,
          'title': 'No hay grabaciones',
          'subtitle': 'Graba tu primer audio para verlo aquí',
        };
      default:
        return {
          'icon': Icons.photo_library,
          'title': 'No hay elementos',
          'subtitle': 'Captura fotos o graba audios para verlos aquí',
        };
    }
  }

  void _openMediaItem(BuildContext context, MediaItem item, AppProvider provider) {
    if (item.type == MediaType.photo) {
      _showPhotoDialog(context, item);
    } else {
      _openAudioPlayer(context, item);
    }
  }

  void _showPhotoDialog(BuildContext context, MediaItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.file(
                File(item.path),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.white, size: 64),
                        SizedBox(height: 16),
                        Text(
                          'No se pudo cargar la imagen',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAudioPlayer(BuildContext context, MediaItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioPlayerScreen(audioItem: item),
      ),
    );
  }

  void _playAudioItem(BuildContext context, MediaItem item, AppProvider provider) {
    provider.playAudio(item);
  }

  void _showItemOptions(BuildContext context, MediaItem item, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Información'),
            onTap: () {
              Navigator.pop(context);
              _showItemInfo(context, item);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Compartir'),
            onTap: () {
              Navigator.pop(context);
              _shareItem(item);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteItem(context, item, provider);
            },
          ),
        ],
      ),
    );
  }

  void _showItemInfo(BuildContext context, MediaItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información del archivo'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow('Nombre:', item.name),
            _buildInfoRow('Tipo:', item.type == MediaType.photo ? 'Foto' : 'Audio'),
            _buildInfoRow('Tamaño:', item.getFormattedSize()),
            _buildInfoRow('Fecha:', _formatDate(item.createdAt)),
            if (item.type == MediaType.audio && item.duration != null)
              _buildInfoRow('Duración:', item.getFormattedDuration()),
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

  void _shareItem(MediaItem item) {
    // Aquí implementarías la funcionalidad de compartir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de compartir no implementada')),
    );
  }

  void _deleteItem(BuildContext context, MediaItem item, AppProvider provider) {
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
              Navigator.pop(context);
              provider.deleteMediaItem(item);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar todo'),
        content: const Text('¿Estás seguro de que quieres eliminar todos los elementos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllItems();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar todo'),
          ),
        ],
      ),
    );
  }

  void _deleteAllItems() {
    // Implementar eliminar todos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función no implementada')),
    );
  }

  void _sortByDate() {
    // Implementar ordenamiento por fecha
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ordenando por fecha...')),
    );
  }

  void _sortByName() {
    // Implementar ordenamiento por nombre
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ordenando por nombre...')),
    );
  }

  void _sortBySize() {
    // Implementar ordenamiento por tamaño
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ordenando por tamaño...')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}