import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presenters/media/media_presenter.dart';
import '../widgets/media_section.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    
    // تشخیص اسکرول برای تغییر رنگ هدر بالا
    _scrollController.addListener(() {
      if (_scrollController.offset > 20 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 20 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });

    // فراخوانی مستقیم متدهای پرزنتر در زمان لود صفحه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final presenter = Provider.of<MediaPresenter>(context, listen: false);
      presenter.getPopularMovies();
      presenter.getPopularSeries();
      presenter.getTrending();
    });
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
      body: Stack(
        children: [
          // 1. لیست اسکرول شونده اصلی
          RefreshIndicator(
            color: const Color(0xFFF08DA5),
            onRefresh: () async {
              final presenter = Provider.of<MediaPresenter>(context, listen: false);
              await presenter.getPopularMovies();
              await presenter.getPopularSeries();
              await presenter.getTrending();
            },
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 100, bottom: 90),
              children: [
                _buildSearchBar(),
                const SizedBox(height: 24),
                
                // گوش دادن به تغییرات MediaPresenter
                Consumer<MediaPresenter>(
                  builder: (context, presenter, child) {
                    if (presenter.isLoading && presenter.popularMovies.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(color: Color(0xFFF08DA5)),
                        ),
                      );
                    }
                    
                    return Column(
                      children: [
                        MediaSection(
                          title: 'Popular Movies',
                          items: presenter.popularMovies,
                          onMoreTap: () {
                            // رفتن به صفحه لیست کامل فیلم‌های محبوب
                          },
                        ),
                        const SizedBox(height: 24),
                        MediaSection(
                          title: 'Popular Series',
                          items: presenter.popularSeries,
                          onMoreTap: () {
                            // رفتن به صفحه لیست کامل سریال‌ها
                          },
                        ),
                        const SizedBox(height: 24),
                        MediaSection(
                          title: 'Trending Now',
                          items: presenter.trendingItems,
                          onMoreTap: () {},
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // 2. هدر بالا (App Bar سفارشی)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopAppBar(),
          ),

          // 3. نوار ناوبری پایین
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 80, 
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16, right: 16,
      ),
      decoration: BoxDecoration(
        color: _isScrolled
            ? const Color(0xFF00161F).withOpacity(0.95)
            : const Color(0xFF00161F).withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF193846).withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF08DA5), Color(0xFF6C5FA6)],
              ),
            ),
            child: const Icon(Icons.movie, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFF08DA5), Color(0xFF6C5FA6)],
            ).createShader(bounds),
            child: const Text(
              'TV Time',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          // کلیک روی این بخش، کاربر را به صفحه جستجو می‌برد
          Navigator.pushNamed(context, '/search');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF193846).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF193846).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF6C5FA6)),
              const SizedBox(width: 12),
              Text(
                'Search movies, series...',
                style: TextStyle(
                  color: const Color(0xFFBCC9C8).withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}