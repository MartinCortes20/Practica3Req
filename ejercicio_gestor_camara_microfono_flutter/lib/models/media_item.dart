enum MediaType {
  photo,
  audio,
}

class MediaItem {
  final String id;
  final String path;
  final String name;
  final MediaType type;
  final DateTime createdAt;
  final int? duration; // Para audio en segundos
  final double? fileSize; // En bytes
  final Map<String, dynamic>? metadata;

  MediaItem({
    required this.id,
    required this.path,
    required this.name,
    required this.type,
    required this.createdAt,
    this.duration,
    this.fileSize,
    this.metadata,
  });

  // Convertir a Map para base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'name': name,
      'type': type.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'duration': duration,
      'fileSize': fileSize,
      'metadata': metadata?.toString(),
    };
  }

  // Crear desde Map de base de datos
  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      id: map['id'],
      path: map['path'],
      name: map['name'],
      type: MediaType.values[map['type']],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      duration: map['duration'],
      fileSize: map['fileSize']?.toDouble(),
      metadata: map['metadata'] != null 
          ? <String, dynamic>{'raw': map['metadata']}
          : null,
    );
  }

  // Crear copia con modificaciones
  MediaItem copyWith({
    String? id,
    String? path,
    String? name,
    MediaType? type,
    DateTime? createdAt,
    int? duration,
    double? fileSize,
    Map<String, dynamic>? metadata,
  }) {
    return MediaItem(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      metadata: metadata ?? this.metadata,
    );
  }

  // Obtener tamaño formateado
  String getFormattedSize() {
    if (fileSize == null) return 'Desconocido';
    
    final size = fileSize!;
    if (size < 1024) {
      return '${size.toInt()} B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Obtener duración formateada (para audio)
  String getFormattedDuration() {
    if (duration == null) return '';
    
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'MediaItem(id: $id, name: $name, type: $type, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}