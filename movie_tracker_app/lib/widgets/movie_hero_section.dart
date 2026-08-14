import 'package:flutter/material.dart';

class MovieHeroSection extends StatelessWidget {
  final String title;
  final String year;
  final String? backdropUrl;
  final double imdbRating;
  final double userRating;
  final List<String> genres;
  final String duration;
  final String country;

  const MovieHeroSection({
    super.key,
    required this.title,
    required this.year,
    this.backdropUrl,
    required this.imdbRating,
    required this.userRating,
    required this.genres,
    required this.duration,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    String finalBackdrop = '';
    if (backdropUrl != null && backdropUrl!.startsWith('/')) {
      finalBackdrop = 'https://image.tmdb.org/t/p/w1280$backdropUrl';
    } else if (backdropUrl != null) {
      finalBackdrop = backdropUrl!;
    }

    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.75,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (finalBackdrop.isNotEmpty)
            Image.network(
              finalBackdrop,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF193846)),
            )
          else
            Container(color: const Color(0xFF193846)),

          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00161F),
                  const Color(0xFF00161F).withOpacity(0.5),
                  const Color(0xFF00161F).withOpacity(0.0),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: genres.map((genre) {
                    bool isFirst = genres.indexOf(genre) % 2 == 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isFirst 
                            ? const Color(0x3329B5B5)
                            : const Color(0x336C5FA6),
                        border: Border.all(
                          color: isFirst 
                              ? const Color(0x4D5AD9D9) 
                              : const Color(0x4D6C5FA6),
                        ),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        genre,
                        style: TextStyle(
                          color: isFirst ? const Color(0xFF5AD9D9) : const Color(0xFF6C5FA6),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                Text(
                  year.isNotEmpty ? '$title ($year)' : title,
                  style: const TextStyle(
                    color: Color(0xFF5AD9D9),
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: -1,
                    shadows: [
                      Shadow(
                        color: Color(0x665AD9D9),
                        blurRadius: 20,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (imdbRating > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x3329B5B5),
                          border: Border.all(color: const Color(0x4D5AD9D9)),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Color(0xFF5AD9D9), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'امتیاز IMDb ${imdbRating.toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: Color(0xFF5AD9D9),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    if (userRating > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x336C5FA6),
                          border: Border.all(color: const Color(0x4D6C5FA6)),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite, color: Color(0xFFF08DA5), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'امتیاز کاربران ${userRating.toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: Color(0xFFF08DA5),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (country.isNotEmpty || duration.isNotEmpty)
                      Text(
                        [if (country.isNotEmpty) country, if (duration.isNotEmpty) duration].join(' • '),
                        style: TextStyle(
                          color: const Color(0xFFBCC9C8).withOpacity(0.6),
                          fontSize: 14,
                          fontFamily: 'Manrope',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}