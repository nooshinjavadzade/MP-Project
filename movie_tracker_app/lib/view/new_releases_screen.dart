import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// مسیر فایل‌های پروژه خود را اینجا وارد کنید
import '../theme/app_colors.dart';
import '../widgets/movie_grid_item.dart';
import '../widgets/custom_search_bar.dart';
import '../presenters/media/media_presenter.dart';


class NewReleasesScreen extends StatefulWidget {
  const NewReleasesScreen({super.key});

  @override
  State<NewReleasesScreen> createState() => _NewReleasesScreenState();
}

class _NewReleasesScreenState extends State<NewReleasesScreen> {
  @override
  void initState() {
    super.initState();
    // دریافت آثار جدید (ترندینگ) در هنگام باز شدن صفحه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MediaPresenter>().getTrending(mediaType: 'all', timeWindow: 'week');
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
            Icon(Icons.new_releases, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'New Releases',
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
          // Background Atmospheric Glows
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

          // گوش دادن به تغییرات MediaPresenter
          Consumer<MediaPresenter>(
            builder: (context, presenter, child) {
              if (presenter.isLoading && presenter.trendingItems.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (presenter.errorMessage != null && presenter.trendingItems.isEmpty) {
                return Center(
                  child: Text(
                    presenter.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final items = presenter.trendingItems;

              if (items.isEmpty && !presenter.isLoading) {
                return const Center(
                  child: Text(
                    'No new releases found.',
                    style: TextStyle(color: AppColors.onBackground),
                  ),
                );
              }

              return CustomScrollView(
                slivers: [
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomSearchBar(
                        hintText: 'Search in New Releases...',
                        onChanged: (value) {
                          // می‌توانید منطق جستجو را اضافه کنید (اختیاری)
                          // presenter.searchMedia(value);
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
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = items[index];
                          
                          // ساختن زیرنویس (مثلاً نوع مدیا و سال)
                          final releaseYear = item.releaseYear?.toString() ?? '';
                          final mediaTypeStr = item.mediaType.name.toUpperCase();
                          final subtitle = releaseYear.isNotEmpty 
                              ? '$mediaTypeStr • $releaseYear' 
                              : mediaTypeStr;

                          return MovieGridItem(
                            title: item.title,
                            imageUrl: item.posterUrl ?? '',
                            rating: (item.tmdbRating ?? 0.0).toStringAsFixed(1),
                            subtitle: subtitle,
                            onTap: () {
                              // ناوبری به صفحه جزئیات با पास دادن ID و نوع مدیا
                              // Navigator.push(...);
                            },
                          );
                        },
                        childCount: items.length,
                      ),
                    ),
                  ),

                  // فضایی برای اسکرول راحت‌تر در انتها
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32.0),
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