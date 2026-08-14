import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../presenters/media/media_presenter.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'series_detail_screen.dart';
import '../widgets/media_grid_card.dart';
import '../widgets/background_glows.dart';

class PopularSeriesScreen extends StatefulWidget {
  const PopularSeriesScreen({super.key});

  @override
  State<PopularSeriesScreen> createState() => _PopularSeriesScreenState();
}

class _PopularSeriesScreenState extends State<PopularSeriesScreen> {
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  int _currentNavIndex = 0; // Home is active by default as per HTML

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // initial load done by Home screen, or we can fetch page 1
      // context.read<MediaPresenter>().getPopularSeries();
    });
  }

  void _onNavTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });
    // TODO: Handle navigation based on index
  }

    void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!context.read<MediaPresenter>().isLoading) {
        _currentPage++;
        context.read<MediaPresenter>().getPopularSeries(/* page: _currentPage */); // pass page if supported
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00161F),
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: const Color(0x9900161F), // surface/60
              elevation: 0,
              centerTitle: false,
              titleSpacing: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFBCC9C8)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Row(
                children: [
                  Icon(Icons.movie_filter, color: Color(0xFF5AD9D9)),
                  SizedBox(width: 12),
                  Text(
                    'Popular Series',
                    style: TextStyle(
                      color: Color(0xFF5AD9D9),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: const Color(0xFF3C4949).withOpacity(0.2), // outline-variant/20
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
          Consumer<MediaPresenter>(
            builder: (context, presenter, child) {
              final allSeries = presenter.popularSeries;
              final filteredSeries = _searchQuery.isEmpty 
                  ? allSeries 
                  : allSeries.where((s) => s.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 80,
                        left: 16,
                        right: 16,
                        bottom: 24,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C2E3B), // surface-container-high
                          borderRadius: BorderRadius.circular(12),
                          border: const Border(
                            bottom: BorderSide(color: Color(0x4D29B5B5), width: 2), // border-primary-container/30
                          ),
                        ),
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          style: const TextStyle(
                            color: Color(0xFFC7E7F8), 
                            fontSize: 16, 
                            fontFamily: 'Manrope',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search in Popular Series...',
                            hintStyle: TextStyle(color: const Color(0xFFBCC9C8).withOpacity(0.4)),
                            prefixIcon: const Icon(Icons.search, color: Color(0x995AD9D9)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  if (presenter.isLoading && allSeries.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF5AD9D9))),
                    )
                  else if (filteredSeries.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No series found.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.50, // 2/3 for image + extra for text
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return MediaGridCard(
                              media: filteredSeries[index],
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => SeriesDetailScreen(tmdbId: int.parse(filteredSeries[index].tmdbId))));
                              },
                            );
                          },
                          childCount: filteredSeries.length,
                        ),
                      ),
                    ),
                ],
              );
            },
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
