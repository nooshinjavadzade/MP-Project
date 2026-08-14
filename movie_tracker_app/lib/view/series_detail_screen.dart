import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

import '../../presenters/media/media_presenter.dart';
import '../widgets/movie_synopsis_card.dart'; // We can reuse this since it's just a text card
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/review_section.dart';
import '../widgets/episode_card.dart';

class SeriesDetailScreen extends StatefulWidget {
  final int tmdbId;

  const SeriesDetailScreen({
    super.key,
    required this.tmdbId,
  });

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  int _selectedSeasonIndex = 0;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MediaPresenter>().getSeriesDetails(widget.tmdbId);
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
      backgroundColor: const Color(0xFF00161F), // background
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: const Color(0x99193846), // surface-variant/60
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF5AD9D9)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.movie, color: Color(0xFF5AD9D9)),
                  SizedBox(width: 8),
                  Text(
                    'TV Time',
                    style: TextStyle(
                      color: Color(0xFF5AD9D9),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  height: 1,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0x333C4949), // outline-variant/20
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<MediaPresenter>(
        builder: (context, presenter, child) {
          if (presenter.isLoading && presenter.seriesDetails == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5AD9D9)),
            );
          }

          if (presenter.errorMessage != null && presenter.seriesDetails == null) {
            return Center(
              child: Text(
                presenter.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final details = presenter.seriesDetails;
          if (details == null) {
            return const Center(
              child: Text(
                'Series not found.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          final String title = details.title;
          final String year = details.releaseYear?.toString() ?? '';
          final String status = details.status;
          final String country = details.country ?? '';
          final String synopsis = details.overview ?? '';
          final String? backdropUrl = details.backdropUrl;
          final double imdbRating = details.tmdbRating ?? 0.0;
          
          final seasons = details.seasons;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (backdropUrl != null)
                        Image.network(
                          backdropUrl,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(color: const Color(0xFF193846)),
                        
                      // Gradient overlay
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0x8000161F),
                              Color(0xFF00161F),
                            ],
                            stops: [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                      
                      // Content
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (imdbRating > 0) ...[
                                    const Icon(Icons.star, color: Color(0xFF5AD9D9), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${imdbRating.toStringAsFixed(1)}/10',
                                      style: const TextStyle(
                                        color: Color(0xFF5AD9D9),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(
                                    child: Text(
                                      [if (year.isNotEmpty) year, if (status.isNotEmpty) status, if (country.isNotEmpty) country].join(' • '),
                                      style: TextStyle(
                                        color: const Color(0xFFBCC9C8).withOpacity(0.7),
                                        fontSize: 12,
                                        fontFamily: 'Manrope',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48, // display-lg
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Plus Jakarta Sans',
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Added to Watchlist')),
                                      );
                                    },
                                    icon: const Icon(Icons.add, size: 20),
                                    label: const Text('ADD TO WATCHLIST'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF08DA5), // tertiary
                                      foregroundColor: const Color(0xFF3F0018), // on-tertiary
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                                      elevation: 0,
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Added to Favorites')),
                                      );
                                    },
                                    icon: const Icon(Icons.favorite_border, size: 20),
                                    label: const Text('LIKE'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFC7E7F8), // on-surface
                                      side: const BorderSide(color: Color(0x4D3C4949)), // outline-variant/30
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                                      backgroundColor: const Color(0xFF0C2E3B), // surface-container-high
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Synopsis
                if (synopsis.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: MovieSynopsisCard(synopsis: synopsis),
                  ),

                const SizedBox(height: 32),

                // Season Selector
                if (seasons.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Episodes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Manrope',
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.check_circle, size: 18, color: Color(0xFFF08DA5)),
                          label: const Text(
                            'MARK SEASON AS WATCHED',
                            style: TextStyle(
                              color: Color(0xFFF08DA5),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Manrope',
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Season Tabs
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: seasons.length,
                      itemBuilder: (context, index) {
                        final season = seasons[index];
                        final isSelected = _selectedSeasonIndex == index;
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedSeasonIndex = index;
                              });
                            },
                            borderRadius: BorderRadius.circular(9999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFF08DA5) : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFF08DA5) : const Color(0xFF3C4949),
                                ),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Center(
                                child: Text(
                                  season.title ?? 'SEASON ${season.seasonNumber}',
                                  style: TextStyle(
                                    color: isSelected ? const Color(0xFF3F0018) : const Color(0xFFBCC9C8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Episodes List for Selected Season
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Builder(
                      builder: (context) {
                        final selectedSeason = seasons[_selectedSeasonIndex];
                        final episodes = selectedSeason.episodes;
                        
                        if (episodes.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text(
                                'No episodes available.',
                                style: TextStyle(color: Color(0xFFBCC9C8)),
                              ),
                            ),
                          );
                        }
                        
                        return Column(
                          children: episodes.map((episode) {
                            return EpisodeCard(
                              episodeNumber: episode.episodeNumber,
                              title: episode.title,
                              overview: episode.overview,
                              runtime: episode.runtime,
                              // For demo purposes, we don't have episode image in the model
                              // You can add it to the model if your API provides it
                              imageUrl: null, 
                              onToggleWatched: () {
                                // TODO: Implement watch toggle functionality
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Reviews & Rating
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ReviewSection(tmdbId: widget.tmdbId, mediaType: 'series'),
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

