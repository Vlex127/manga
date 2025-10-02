import 'package:flutter/material.dart';
import 'bookmarks_repository.dart';
import 'models.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilter = 0;
  final BookmarksRepository _repo = BookmarksRepository();
  List<Manga> _bookmarks = [];

  final List<String> filters = ['Recently Read', 'Alphabetical', 'Last Updated'];

  Future<void> _load() async {
    final list = await _repo.loadBookmarks();
    setState(() => _bookmarks = list);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
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
                        _sortBookmarks();
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
                RefreshIndicator(
                  color: Colors.blueAccent,
                  backgroundColor: const Color(0xFF23233A),
                  onRefresh: _load,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _bookmarks.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 80),
                              Center(
                                child: Text(
                                  'No bookmarks yet.',
                                  style: TextStyle(color: Colors.white54, fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              mainAxisSpacing: 24,
                              crossAxisSpacing: 16,
                            ),
                            itemCount: _bookmarks.length,
                            itemBuilder: (context, index) {
                              final m = _bookmarks[index];
                              return _BookmarkCard(manga: m);
                            },
                          ),
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

  void _sortBookmarks() {
    if (_bookmarks.isEmpty) return;
    switch (_selectedFilter) {
      case 0:
        // Recently Read placeholder: keep insertion order
        break;
      case 1:
        _bookmarks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 2:
        // Last Updated placeholder: no data yet, keep order
        break;
    }
  }
}

class _BookmarkCard extends StatelessWidget {
  final Manga manga;

  const _BookmarkCard({required this.manga});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: manga.coverUrl.isNotEmpty
              ? Image.network(
                  manga.coverUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 140,
                  color: const Color(0xFF23233A),
                  child: const Center(
                    child: Icon(Icons.book, color: Colors.white54, size: 32),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Text(
          manga.title,
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