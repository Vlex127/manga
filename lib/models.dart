class Manga {
  final String id;
  final String title;
  final String status;
  final String coverUrl;
  final String description;

  const Manga({
    required this.id,
    required this.title,
    required this.status,
    required this.coverUrl,
    required this.description,
  });

  factory Manga.fromApiJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final attributes = json['attributes'] ?? {};
    final titleMap = attributes['title'] ?? {};

    String resolvedTitle = 'No Title';
    if (titleMap is Map && titleMap.containsKey('en')) {
      resolvedTitle = titleMap['en'];
    } else if (titleMap is Map && titleMap.values.isNotEmpty) {
      resolvedTitle = titleMap.values.first;
    }

    final status = (attributes['status'] ?? 'Unknown').toString();

    final descMap = attributes['description'] ?? {};
    String resolvedDescription = '';
    if (descMap is Map && descMap.containsKey('en')) {
      resolvedDescription = descMap['en'];
    } else if (descMap is Map && descMap.values.isNotEmpty) {
      resolvedDescription = descMap.values.first;
    }

    String coverUrl = '';
    if (json['relationships'] != null) {
      for (final rel in (json['relationships'] as List)) {
        if (rel['type'] == 'cover_art' && rel['attributes'] != null) {
          final fileName = rel['attributes']['fileName'] ?? '';
          if (fileName is String && fileName.isNotEmpty) {
            coverUrl = 'https://uploads.mangadex.org/covers/$id/$fileName.256.jpg';
          }
        }
      }
    }

    return Manga(
      id: id,
      title: resolvedTitle,
      status: status,
      coverUrl: coverUrl,
      description: resolvedDescription,
    );
  }

  factory Manga.fromJson(Map<String, dynamic> json) {
    return Manga(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      coverUrl: json['coverUrl'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'coverUrl': coverUrl,
      'description': description,
    };
  }
}

