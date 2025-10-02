import 'api_client.dart';
import 'models.dart';

class MangaService {
  MangaService([ApiClient? client]) : _api = client ?? ApiClient();

  final ApiClient _api;

  Future<List<Manga>> getMangaPage({required int page, required String sortBy}) async {
    final offset = page * 20;
    final data = await _api.getJson(
      '/manga',
      query: {
        'limit': '20',
        'offset': '$offset',
        'order[$sortBy]': 'desc',
        'includes[]': 'cover_art',
        'contentRating[]': 'safe',
        'contentRating[]': 'suggestive',
        'hasAvailableChapters': 'true',
      },
    );
    final List items = data['data'] as List;
    return items.map((e) => Manga.fromApiJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Manga>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final data = await _api.getJson(
      '/manga',
      query: {
        'title': query,
        'limit': '20',
        'includes[]': 'cover_art',
        'contentRating[]': 'safe',
        'contentRating[]': 'suggestive',
      },
    );
    final List items = data['data'] as List;
    return items.map((e) => Manga.fromApiJson(e as Map<String, dynamic>)).toList();
  }
}

