import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../widgets/movie_grid_item.dart';
import '../widgets/custom_search_bar.dart';

// TODO: کامنت خط زیر را بردارید و مسیر صحیح فایل پرزنتر خود را قرار دهید
// import '../../presenters/media_presenter.dart'; 

import '../presenters/media/media_presenter.dart'; // مسیر فایل MediaPresenter
class PopularSeriesScreen extends StatefulWidget {
  const PopularSeriesScreen({super.key});

  @override
  State<PopularSeriesScreen> createState() => _PopularSeriesScreenState();
}

class _PopularSeriesScreenState extends State<PopularSeriesScreen> {
  
  @override
  void initState() {
    super.initState();
    // فراخوانی متد دریافت سریال‌های محبوب از API هنگام باز شدن صفحه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // TODO: کامنت خط زیر را برای دریافت واقعی داده‌ها بردارید
      // context.read<MediaPresenter>().getPopularSeries();
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
            Icon(Icons.tv, color: AppColors.primary), // آیکون تلویزیون برای سریال‌ها
            SizedBox(width: 8),
            Text(
              'Popular Series',
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
          
          // Consumer برای ارتباط مستقیم با API و MediaPresenter
          
          Consumer<MediaPresenter>(
            builder: (context, presenter, child) {
              // نمایش لودینگ فقط وقتی داده‌ای نداریم
              if (presenter.isLoading && presenter.popularSeries.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              
              // نمایش خطا
              if (presenter.errorMessage != null && presenter.popularSeries.isEmpty) {
                return Center(
                  child: Text(
                    presenter.errorMessage!,
                    style: const TextStyle(color: Colors.red), // یا AppColors.error اگر تعریف کردید
                  ),
                );
              }

              final seriesList = presenter.popularSeries;

              return CustomScrollView(
                slivers: [
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 24.0),
                      child: CustomSearchBar(
                        hintText: 'Search in Popular Series...',
                        onChanged: (value) {
                          // متد جستجوی پرزنتر را اینجا صدا بزنید در صورت نیاز
                          // presenter.searchMedia(value);
                        },
                      ),
                    ),
                  ),
                  
                  // Grid View برای سریال‌ها
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
                          final series = seriesList[index];
                          return MovieGridItem(
                            title: series.title,
                            imageUrl: series.posterUrl ?? '',
                            rating: series.tmdbRating?.toStringAsFixed(1) ?? 'N/A',
                            subtitle: series.releaseYear != null ? '${series.releaseYear}' : '',
                            onTap: () {
                              // هدایت به صفحه جزئیات سریال با استفاده از آیدی
                              // Navigator.pushNamed(context, '/series_details', arguments: series.id);
                            },
                          );
                        },
                        childCount: seriesList.length,
                      ),
                    ),
                  ),
                  
                  // Loading Indicator برای Pagination (وقتی اسکرول به پایین می‌رسد)
                  if (presenter.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      ),
                    ),
                  
                  // فضای خالی برای Bottom Navigation Bar
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