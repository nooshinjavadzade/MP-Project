import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../widgets/movie_grid_item.dart';
import '../widgets/custom_search_bar.dart';

// ⚠️ بسیار مهم: آدرس‌های ایمپورت زیر را دقیقاً با پوشه‌بندی پروژه خودتون تنظیم کنید
 // مسیر فایل MediaPresenter
import '../../models/common/media_base.dart';   // مسیر فایل مدل MediaBase
import '../../presenters/media/media_presenter.dart'; // مسیر فایل MediaPresenter

class PopularMoviesScreen extends StatefulWidget {
  const PopularMoviesScreen({super.key});

  @override
  State<PopularMoviesScreen> createState() => _PopularMoviesScreenState();
}

class _PopularMoviesScreenState extends State<PopularMoviesScreen> {
  
  @override
  void initState() {
    super.initState();
    // فراخوانی API بلافاصله بعد از باز شدن صفحه برای گرفتن لیست فیلم‌های محبوب
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MediaPresenter>().getPopularMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.6),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: const [
            Icon(Icons.movie_filter, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Popular Movies',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // هاله های نورانی پس زمینه (Background Atmospheric Glows)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tertiary.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 150, sigmaY: 150),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          // گوش دادن به تغییرات Provider و دیتای واقعی API
          Consumer<MediaPresenter>(
            builder: (context, presenter, child) {
              
              // 1. حالت لودینگ اولیه
              if (presenter.isLoading && presenter.popularMovies.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)
                );
              }
              
              // 2. حالت ارور و خطا در دریافت اطلاعات
              if (presenter.errorMessage != null && presenter.popularMovies.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          presenter.errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => presenter.getPopularMovies(),
                          child: const Text('تلاش مجدد'),
                        )
                      ],
                    ),
                  ),
                );
              }

              // دریافت اطلاعات از API
              final List<MediaBase> movies = presenter.popularMovies;

              // 3. نمایش اطلاعات واقعی دریافتی
              return CustomScrollView(
                slivers: [
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomSearchBar(
                        hintText: 'Search in Popular Movies...',
                        onChanged: (value) {
                           // سرچ مستقیم در پرزنتر 
                           presenter.searchMedia(value); 
                        },
                      ),
                    ),
                  ),
                  
                  // Grid View
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.55, // نسبت عرض به ارتفاع برای کارت و متن
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final MediaBase movie = movies[index];
                          
                          return MovieGridItem(
                            title: movie.title,
                            imageUrl: movie.posterUrl ?? '',
                            rating: movie.tmdbRating != null ? movie.tmdbRating.toString() : 'N/A',
                            subtitle: movie.releaseYear != null ? movie.releaseYear.toString() : 'Unknown',
                            onTap: () {
                              // ناوبری به صفحه جزئیات با ارسال شناسه مدیا
                              Navigator.pushNamed(context, '/movie_details', arguments: movie.tmdbId);
                            },
                          );
                        },
                        childCount: movies.length,
                      ),
                    ),
                  ),
                  
                  // اگر در حال دریافت صفحات بعدی از API است (لودینگ پایین صفحه)
                  if (presenter.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      ),
                    )
                  else 
                    // فضای خالی برای اسکرول پایین راحت‌تر
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100), 
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}