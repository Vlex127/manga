import 'package:flutter/material.dart';
import 'dart:async';
import 'library.dart';
import 'settings.dart';
import 'updates.dart';
import 'models.dart';
import 'manga_service.dart';
import 'bookmarks_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF181828),
      ),
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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
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

class BrowseMangaScreen extends StatefulWidget {
  const BrowseMangaScreen({super.key});

  @override
  State<BrowseMangaScreen> createState() => _BrowseMangaScreenState();
}

class _BrowseMangaScreenState extends State<BrowseMangaScreen> with AutomaticKeepAliveClientMixin {
  final List<String> genres = [
    'Shonen',
    'Shojo',
    'Seinen',
    'Josei',
    'Action',
    'Romance',
    'Comedy',
    'Drama',
  ];
  final Map<String, int> genreUsage = {};
  String selectedGenre = 'Shonen';
  Future<List<Manga>>? mangaFuture;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MangaService _mangaService = MangaService();
  bool _isSearching = false;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  List<Manga> _allManga = [];
  bool _hasMore = true;
  String _sortBy = 'latestUploadedChapter';
  Timer? _debounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    for (var genre in genres) {
      genreUsage[genre] = 0;
    }
    _scrollController.addListener(_onScroll);
    _loadInitialManga();
  }

  void _loadInitialManga() {
    setState(() {
      _currentPage = 0;
      _allManga = [];
      _hasMore = true;
      mangaFuture = _mangaService.getMangaPage(page: 0, sortBy: _sortBy);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore &&
        !_isSearching) {
      _loadMoreManga();
    }
  }

  Future<void> _loadMoreManga() async {
    if (_isLoadingMore || !_hasMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newManga = await _mangaService.getMangaPage(page: _currentPage + 1, sortBy: _sortBy);
      setState(() {
        _currentPage++;
        _allManga.addAll(newManga);
        _isLoadingMore = false;
        if (newManga.length < 20) {
          _hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<List<Manga>> searchManga(String query) async {
    return _mangaService.search(query);
  }

  void onGenreSelected(String genre) {
    if (!mounted) return;
    setState(() {
      selectedGenre = genre;
      genreUsage[genre] = (genreUsage[genre] ?? 0) + 1;
      genres.sort((a, b) => genreUsage[b]!.compareTo(genreUsage[a]!));
      _isSearching = false;
      _searchController.clear();
      _loadInitialManga();
    });
  }

  void onSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _loadInitialManga();
      });
    } else {
      setState(() {
        _isSearching = true;
        _allManga = [];
        mangaFuture = searchManga(query);
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      onSearch(value);
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF23233A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Sort By',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SortOption(
                title: 'Latest Updates',
                value: 'latestUploadedChapter',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _loadInitialManga();
                  });
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                title: 'Highest Rating',
                value: 'rating',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _loadInitialManga();
                  });
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                title: 'Most Follows',
                value: 'followedCount',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _loadInitialManga();
                  });
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                title: 'Recently Added',
                value: 'createdAt',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _loadInitialManga();
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF23233A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Status',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Ongoing'),
                      selected: false,
                      onSelected: (selected) {},
                      backgroundColor: const Color(0xFF181828),
                      selectedColor: Colors.blueAccent,
                      labelStyle: const TextStyle(color: Colors.white70),
                    ),
                    FilterChip(
                      label: const Text('Completed'),
                      selected: false,
                      onSelected: (selected) {},
                      backgroundColor: const Color(0xFF181828),
                      selectedColor: Colors.blueAccent,
                      labelStyle: const TextStyle(color: Colors.white70),
                    ),
                    FilterChip(
                      label: const Text('Hiatus'),
                      selected: false,
                      onSelected: (selected) {},
                      backgroundColor: const Color(0xFF181828),
                      selectedColor: Colors.blueAccent,
                      labelStyle: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF181828),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181828),
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
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterOptions,
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search manga',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54),
                          onPressed: () {
                            _searchController.clear();
                            onSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF23233A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            if (!_isSearching) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: genres.map((genre) => _GenreChip(
                    genre,
                    selected: genre == selectedGenre,
                    onTap: () => onGenreSelected(genre),
                  )).toList(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isSearching ? 'Search Results' : '$selectedGenre Manga',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  if (!_isSearching)
                    Text(
                      '${_allManga.length} titles',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                color: Colors.blueAccent,
                backgroundColor: const Color(0xFF23233A),
                onRefresh: () async {
                  if (_isSearching) {
                    setState(() {
                      mangaFuture = searchManga(_searchController.text);
                    });
                  } else {
                    _loadInitialManga();
                  }
                  await (mangaFuture ?? Future.value([]));
                },
                child: FutureBuilder<List<Manga>>(
                future: mangaFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _allManga.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.blueAccent),
                    );
                  } else if (snapshot.hasError && _allManga.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load manga',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                mangaFuture = _isSearching 
                                    ? searchManga(_searchController.text)
                                    : fetchMangaByGenre(selectedGenre, 0);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (snapshot.hasData && _allManga.isEmpty) {
                    _allManga = snapshot.data!;
                  }

                  if (_allManga.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.book_outlined, color: Colors.white54, size: 48),
                          SizedBox(height: 16),
                          Text(
                            'No manga found',
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 16,
                        ),
                        itemCount: _allManga.length,
                        itemBuilder: (context, index) {
                          final manga = _allManga[index];
                          return _MangaCard(
                            manga: manga,
                            onTap: () => _showMangaDetails(manga),
                          );
                        },
                      ),
                      if (_isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.blueAccent),
                          ),
                        ),
                      if (!_hasMore && _allManga.isNotEmpty && !_isSearching)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'No more manga to load',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMangaDetails(Manga manga) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MangaDetailsScreen(manga: manga),
      ),
    );
  }
}

class MangaDetailsScreen extends StatefulWidget {
  final Manga manga;

  const MangaDetailsScreen({super.key, required this.manga});

  @override
  State<MangaDetailsScreen> createState() => _MangaDetailsScreenState();
}

class _MangaDetailsScreenState extends State<MangaDetailsScreen> {
  final BookmarksRepository _repo = BookmarksRepository();
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final isBm = await _repo.isBookmarked(widget.manga.id);
    if (mounted) setState(() => _bookmarked = isBm);
  }

  Future<void> _toggle() async {
    await _repo.toggleBookmark(widget.manga);
    if (mounted) setState(() => _bookmarked = !_bookmarked);
  }

  @override
  Widget build(BuildContext context) {
    final manga = widget.manga;
    return Scaffold(
      backgroundColor: const Color(0xFF181828),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF181828),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (manga.coverUrl.isNotEmpty)
                    Image.network(
                      manga.coverUrl,
                      fit: BoxFit.cover,
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF181828).withOpacity(0.8),
                          const Color(0xFF181828),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: _toggle,
                icon: Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_border),
                color: Colors.white,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      manga.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Read Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _toggle,
                        icon: Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_border),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF23233A),
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF23233A),
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    manga.description.isNotEmpty
                        ? manga.description
                        : 'No description available.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chapters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF23233A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            'Chapter ${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            '2 days ago',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          trailing: const Icon(Icons.download_outlined, color: Colors.white54),
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

 

class _GenreChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  
  const _GenreChip(this.label, {this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: selected,
        selectedColor: Colors.blueAccent,
        backgroundColor: const Color(0xFF23233A),
        onSelected: (_) => onTap?.call(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _MangaCard extends StatelessWidget {
  final Manga manga;
  final VoidCallback onTap;
  
  const _MangaCard({
    required this.manga,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Hero(
              tag: manga.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: manga.coverUrl.isNotEmpty
                    ? Image.network(
                        manga.coverUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: const Color(0xFF23233A),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.blueAccent,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF23233A),
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.white54, size: 32),
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFF23233A),
                        child: const Center(
                          child: Icon(Icons.book, color: Colors.white54, size: 32),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            manga.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            manga.status.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white54,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String?>? onChanged;

  const _SortOption({
    required this.title,
    required this.value,
    required this.groupValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Colors.blueAccent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}