import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../presenters/media/media_presenter.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/background_glows.dart';
import '../widgets/media_grid_card.dart';
import 'movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'همه';
  final List<String> _filters = ['همه', 'نام', 'سال', 'کارگردان', 'بازیگر', 'ژانر'];
  int _currentNavIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (value.isNotEmpty) {
      context.read<MediaPresenter>().searchMedia(value);
    } else {
      setState(() {});
    }
  }

  void _onHistoryTapped(String query) {
    _searchController.text = query;
    context.read<MediaPresenter>().searchMedia(query);
    setState(() {});
  }

  void _onNavTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2D3A),
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: const Color(0xCC00161F),
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'TV Time',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Plus Jakarta Sans',
                  letterSpacing: -0.5,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: Colors.white.withOpacity(0.05),
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const BackgroundGlows(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x330F5F66),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'جستجو بر اساس عنوان...',
                        hintStyle: TextStyle(
                          color: const Color(0xFFBCC9C8).withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF08DA5)
                                    : const Color(0xFF193846).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFF08DA5)
                                      : Colors.white.withOpacity(0.1),
                                ),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: const Color(0xFFF08DA5).withOpacity(0.4),
                                    blurRadius: 10,
                                  )
                                ] : null,
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF00161F) : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: Consumer<MediaPresenter>(
                      builder: (context, presenter, child) {
                        if (presenter.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(color: Color(0xFFF08DA5)),
                          );
                        }

                        if (_searchController.text.isEmpty) {
                          final history = presenter.searchHistory;
                          if (history.isEmpty) {
                            return const Center(
                              child: Text(
                                'تاریخچه جستجویی وجود ندارد.',
                                style: TextStyle(color: Colors.white54),
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'جستجوهای اخیر',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => presenter.clearSearchHistory(),
                                    child: const Text(
                                      'پاک کردن همه',
                                      style: TextStyle(
                                        color: Color(0xFFF08DA5),
                                        fontSize: 12,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: history.length,
                                  separatorBuilder: (_, __) => Divider(
                                    color: Colors.white.withOpacity(0.05),
                                    height: 1,
                                  ),
                                  itemBuilder: (context, index) {
                                    final query = history[index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.history, color: Colors.white54, size: 20),
                                      title: Text(
                                        query,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'Manrope',
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                                        onPressed: () => presenter.removeSearchQuery(query),
                                      ),
                                      onTap: () => _onHistoryTapped(query),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }

                        final searchResult = presenter.searchResult;
                        final results = searchResult?.items ?? [];
                        if (results.isEmpty) {
                          return const Center(
                            child: Text(
                              'هیچ نتیجه‌ای یافت نشد.',
                              style: TextStyle(color: Colors.white54),
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.only(bottom: 120),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.50,
                          ),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            return MediaGridCard(
                              media: results[index],
                              onTap: () {
                                if (results[index].mediaType.toString().toLowerCase().contains('movie')) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MovieDetailScreen(movieId: results[index].id),
                                    ),
                                  );
                                } else {
                                  // TODO: Navigate to Series Detail
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}