import 'package:flutter/material.dart';
import 'library.dart'; // Make sure this file exists and exports LibraryScreen

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
    // Add other screens if needed
    Center(child: Text('Updates', style: TextStyle(color: Colors.white))),
    Center(child: Text('Settings', style: TextStyle(color: Colors.white))),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Updates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class BrowseMangaScreen extends StatelessWidget {
  const BrowseMangaScreen({super.key});

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
                children: [
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
              'For You',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.7,
              mainAxisSpacing: 20,
              crossAxisSpacing: 16,
              children: [
                _MangaCard(
                  image: 'assets/anya.png',
                  title: "The Shadow's Embr...",
                  subtitle: "A tale of mystery",
                ),
                _MangaCard(
                  image: 'assets/izumi.png',
                  title: "Crimson Echoes",
                  subtitle: "A thrilling adventure",
                ),
                _MangaCard(
                  image: 'assets/naruto.png',
                  title: "Whispers of the Past",
                  subtitle: "Unraveling secrets",
                ),
              ],
            ),
          ],
        ),
      ),
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
          child: Image.asset(
            image,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
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