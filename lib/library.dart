import 'package:flutter/material.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilter = 0;

  final List<String> filters = ['Recently Read', 'Alphabetical', 'Last Updated'];

  final List<Map<String, String>> mangaList = [
    {'image': 'assets/naruto.png', 'title': 'The Shadowed Throne'},
    {'image': 'assets/izumi.png', 'title': 'Crimson Echoes'},
    {'image': 'assets/anya.png', 'title': 'Whispers of the Past'},
    {'image': 'assets/izumi.png', 'title': 'Eternal Nightfall'},
    {'image': 'assets/naruto.png', 'title': 'The Lost Heirloom'},
    {'image': 'assets/anya.png', 'title': 'Serpent\'s Kiss'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181828),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Library',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          indicatorWeight: 2,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          tabs: const [
            Tab(text: 'Manga'),
            Tab(text: 'Novels'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF181828),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: List.generate(filters.length, (index) {
                final selected = _selectedFilter == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(
                      filters[index],
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    selected: selected,
                    selectedColor: Colors.blueAccent,
                    backgroundColor: const Color(0xFF23233A),
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = index;
                      });
                    },
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Manga Tab
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 16,
                    children: mangaList.map((manga) {
                      return _MangaCard(
                        image: manga['image']!,
                        title: manga['title']!,
                      );
                    }).toList(),
                  ),
                ),
                // Novels Tab (empty for now)
                const Center(
                  child: Text(
                    'No novels in your library.',
                    style: TextStyle(color: Colors.white54, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MangaCard extends StatelessWidget {
  final String image;
  final String title;

  const _MangaCard({required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            image,
            height: 140,
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
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}