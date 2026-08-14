import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../presenters/media/media_presenter.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/media_grid_card.dart';
import '../widgets/movie_hero_section.dart';
import '../widgets/movie_action_buttons.dart';
import '../widgets/movie_synopsis_card.dart';
import '../widgets/review_section.dart';
import '../widgets/movie_cast_card.dart';
import '../widgets/report_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MediaPresenter>().getMovieDetails(widget.movieId);
    });
  }

  void _onNavTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ReportDialog(
        tmdbId: widget.movieId,
        mediaType: 'movie',
      ),
    );
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
              backgroundColor: const Color(0x99193846),
              elevation: 0,
              centerTitle: false,
              titleSpacing: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Row(
                children: [
                  Icon(Icons.movie, color: Color(0xFFF08DA5)),
                  SizedBox(width: 12),
                  Text(
                    'TV Time',
                    style: TextStyle(
                      color: Color(0xFF5AD9D9),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  height: 1,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0x333C4949),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0DF08DA5),
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<MediaPresenter>(
        builder: (context, presenter, child) {
          if (presenter.isLoading && presenter.movieDetails == null) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5AD9D9)));
          }

          if (presenter.errorMessage != null && presenter.movieDetails == null) {
            return Center(child: Text(presenter.errorMessage!, style: const TextStyle(color: Colors.red)));
          }

          final details = presenter.movieDetails;
          final String title = details?.title ?? '';
          final String year = details?.releaseYear?.toString() ?? '';
          final String? backdropUrl = details?.backdropUrl;
          final double imdbRating = details?.tmdbRating ?? 0.0;
          final double userRating = details?.communityRating ?? 0.0;
          
          final List<String> genres = []; 
          final String duration = '';
          final String country = '';
          final String synopsis = details?.overview ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MovieHeroSection(
                  title: title,
                  year: year,
                  backdropUrl: backdropUrl,
                  imdbRating: imdbRating,
                  userRating: userRating,
                  genres: genres,
                  duration: duration,
                  country: country,
                ),
                
                const SizedBox(height: 32),

                MovieActionButtons(
                  onWatchlistTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('به لیست تماشا اضافه شد')),
                    );
                  },
                  onLikeTap: () {
                    presenter.toggleLike(widget.movieId.toString(), 'movie');
                  },
                  onReportTap: _showReportDialog,
                ),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMd = constraints.maxWidth >= 768;
                      if (isMd) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: MovieSynopsisCard(synopsis: synopsis),
                            ),
                            const SizedBox(width: 24),
                            const Expanded(
                              flex: 1,
                              child: MovieCastCard(cast: []),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            MovieSynopsisCard(synopsis: synopsis),
                            const SizedBox(height: 24),
                            const MovieCastCard(cast: []),
                          ],
                        );
                      }
                    }
                  ),
                ),

                const SizedBox(height: 32),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ReviewSection(tmdbId: widget.movieId, mediaType: 'movie'),
                ),

                const SizedBox(height: 48),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'بیشتر شبیه به این',
                        style: TextStyle(
                          color: Color(0xFF5AD9D9),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 24),
                      GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: presenter.trendingItems.take(4).length,
                        itemBuilder: (context, index) {
                          return MediaGridCard(
                            media: presenter.trendingItems[index],
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => MovieDetailScreen(
                                  movieId: presenter.trendingItems[index].id,
                                ),
                              ));
                            },
                          );
                        },
                      ),
                    ],
                  ),
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