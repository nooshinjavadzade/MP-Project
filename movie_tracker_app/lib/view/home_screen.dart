import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../presenters/media/media_presenter.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/fake_search_bar.dart';
import '../widgets/horizontal_media_list.dart';
import 'popular_movies_screen.dart';
import 'movie_detail_screen.dart';
import 'series_detail_screen.dart';
import 'popular_series_screen.dart';
import 'search_screen.dart';
import 'trending_screen.dart';
import 'watchlist_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentNavIndex;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialIndex;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final presenter = context.read<MediaPresenter>();
      presenter.getPopularMovies();
      presenter.getPopularSeries();
      presenter.getTrending(timeWindow: 'week');
    });
  }

  void _onNavTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00161F),
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: _currentNavIndex == 0 ? const HomeAppBar() : null,
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildHomeBody(),
          const WatchlistScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTapped,
      ),
    );
  }

  Widget _buildHomeBody() {
    return Consumer<MediaPresenter>(
      builder: (context, presenter, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: kToolbarHeight + 32,
            bottom: 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FakeSearchBar(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
                },
              ),
              const SizedBox(height: 32),
              
              HorizontalMediaList(
                title: 'فیلم‌های محبوب',
                items: presenter.popularMovies,
                isLoading: presenter.isLoading && presenter.popularMovies.isEmpty,
                onMoreTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PopularMoviesScreen()));
                },
                onItemTap: (media) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailScreen(movieId: media.id),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              
              HorizontalMediaList(
                title: 'سریال‌های محبوب',
                items: presenter.popularSeries,
                isLoading: presenter.isLoading && presenter.popularSeries.isEmpty,
                onMoreTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PopularSeriesScreen()));
                },
                onItemTap: (media) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SeriesDetailScreen(tmdbId: int.parse(media.tmdbId))));
                  debugPrint('Navigate to Series Detail: $media');
                },
              ),
              const SizedBox(height: 32),
              
              HorizontalMediaList(
                title: 'آخرین انتشارها',
                items: presenter.trendingItems,
                isLoading: presenter.isLoading && presenter.trendingItems.isEmpty,
                onMoreTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TrendingScreen()));
                },
                onItemTap: (media) {
                  if (media.mediaType.toString().toLowerCase().contains('movie')) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(movieId: media.id),
                      ),
                    );
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SeriesDetailScreen(tmdbId: int.parse(media.tmdbId))));
                    debugPrint('Navigate to Series Detail: $media');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}