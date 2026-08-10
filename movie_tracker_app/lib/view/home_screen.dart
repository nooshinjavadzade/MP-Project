import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../presenters/media/media_presenter.dart'; // حتما مسیر ایمپورت را بر اساس ساختار پروژه تنظیم کنید
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/fake_search_bar.dart';
import '../widgets/horizontal_media_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // فراخوانی متدهای پرزنتر بلافاصله پس از بیلد اولیه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final presenter = context.read<MediaPresenter>();
      presenter.getPopularMovies();
      presenter.getPopularSeries();
      // به عنوان New Releases از ترندینگ استفاده می‌کنیم
      presenter.getTrending(timeWindow: 'week');
    });
  }

  void _onNavTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });
    // اینجا اگر لازم باشد صفحات دیگر رو رندر می‌کنید یا با PageView هندل می‌کنید
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00161F), // bg-background
      extendBodyBehindAppBar: true,
      extendBody: true, // برای اینکه لیست زیر باتم نوبار برود (pb-safe)
      appBar: const HomeAppBar(),
      body: Consumer<MediaPresenter>(
        builder: (context, presenter, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              top: kToolbarHeight + 32, // فاصله از اپ‌بار
              bottom: 100, // pb-24 padding for bottom nav
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // سرچ بار
                FakeSearchBar(
                  onTap: () {
                    // TODO: Navigate to Search Screen
                    debugPrint('Navigate to search screen');
                  },
                ),
                const SizedBox(height: 32), // space-y-8
                
                // Popular Movies
                HorizontalMediaList(
                  title: 'Popular Movies',
                  items: presenter.popularMovies,
                  isLoading: presenter.isLoading && presenter.popularMovies.isEmpty,
                  onMoreTap: () {
                    // TODO: Navigate to full popular movies list screen
                    debugPrint('Navigate to Popular Movies');
                  },
                  onItemTap: (media) {
                    // TODO: Navigate to Media Detail Screen
                    debugPrint('Navigate to Movie Detail: $media');
                  },
                ),
                const SizedBox(height: 32),
                
                // Popular Series
                HorizontalMediaList(
                  title: 'Popular Series',
                  items: presenter.popularSeries,
                  isLoading: presenter.isLoading && presenter.popularSeries.isEmpty,
                  onMoreTap: () {
                    // TODO: Navigate to full popular series list screen
                    debugPrint('Navigate to Popular Series');
                  },
                  onItemTap: (media) {
                    // TODO: Navigate to Media Detail Screen
                    debugPrint('Navigate to Series Detail: $media');
                  },
                ),
                const SizedBox(height: 32),
                
                // New Releases (Trending)
                HorizontalMediaList(
                  title: 'New Releases',
                  items: presenter.trendingItems,
                  isLoading: presenter.isLoading && presenter.trendingItems.isEmpty,
                  onMoreTap: () {
                    // TODO: Navigate to full trending list screen
                    debugPrint('Navigate to Trending');
                  },
                  onItemTap: (media) {
                    // TODO: Navigate to Media Detail Screen
                    debugPrint('Navigate to Detail: $media');
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}
