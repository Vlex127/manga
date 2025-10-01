import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'library.dart';
import 'settings.dart';
import 'updates.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const BrowseMangaScreen(),
    const LibraryScreen(),
    const UpdatesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181828),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF181828),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Updates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class BrowseMangaScreen extends StatelessWidget {
  const BrowseMangaScreen({super.key});

  Future<List<Manga>> fetchLatestManga() async {
    final url = Uri.parse('https://api.mangadex.org/manga?limit=10&order[latestUploadedChapter]=desc&includes[]=cover_art');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List mangaList = data['data'];
      return mangaList.map((m) => Manga.fromJson(m)).toList();
    } else {
      throw Exception('Failed to load manga');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181828),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Browse',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search manga',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF23233A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _GenreChip('Shonen', selected: true),
                  _GenreChip('Shojo'),
                  _GenreChip('Seinen'),
                  _GenreChip('Josei'),
                  _GenreChip('Action'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Latest Manga',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Manga>>(
              future: fetchLatestManga(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load manga', style: TextStyle(color: Colors.white)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No manga found', style: TextStyle(color: Colors.white)));
                }
                final mangaList = snapshot.data!;
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 16,
                  children: mangaList.map((manga) => _MangaCard(
                    image: manga.coverUrl,
                    title: manga.title,
                    subtitle: manga.status,
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Manga {
  final String id;
  final String title;
  final String status;
  final String coverUrl;

  Manga({required this.id, required this.title, required this.status, required this.coverUrl});

  factory Manga.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final attributes = json['attributes'] ?? {};
    final titleMap = attributes['title'] ?? {};
    final title = titleMap.values.isNotEmpty ? titleMap.values.first : 'No Title';
    final status = attributes['status'] ?? '';
    String coverUrl = '';
    if (json['relationships'] != null) {
      for (var rel in json['relationships']) {
        if (rel['type'] == 'cover_art') {
          final fileName = rel['attributes']?['fileName'] ?? '';
          coverUrl = 'https://uploads.mangadex.org/covers/$id/$fileName.256.jpg';
        }
      }
    }
    return Manga(
      id: id,
      title: title,
      status: status,
      coverUrl: coverUrl,
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _GenreChip(this.label, {this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.white70)),
        selected: selected,
        selectedColor: Colors.blueAccent,
        backgroundColor: const Color(0xFF23233A),
        onSelected: (_) {},
      ),
    );
  }
}

class _MangaCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  const _MangaCard({required this.image, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: image.isNotEmpty
              ? Image.network(
                  image,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    color: Colors.grey.shade800,
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.white54)),
                  ),
                )
              : Container(
                  height: 160,
                  color: Colors.grey.shade800,
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.white54)),
                ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white54,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}