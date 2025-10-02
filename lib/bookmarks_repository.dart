import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class BookmarksRepository {
  static const String _key = 'bookmarked_manga_v1';

  Future<List<Manga>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) return [];
    final decoded = json.decode(jsonString) as List<dynamic>;
    return decoded.map((e) => Manga.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveBookmarks(List<Manga> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(bookmarks.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  Future<bool> isBookmarked(String mangaId) async {
    final bookmarks = await loadBookmarks();
    return bookmarks.any((m) => m.id == mangaId);
  }

  Future<void> toggleBookmark(Manga manga) async {
    final bookmarks = await loadBookmarks();
    final existingIndex = bookmarks.indexWhere((m) => m.id == manga.id);
    if (existingIndex >= 0) {
      bookmarks.removeAt(existingIndex);
    } else {
      bookmarks.insert(0, manga);
    }
    await saveBookmarks(bookmarks);
  }
}

