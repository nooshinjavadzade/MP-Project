import 'package:flutter/material.dart';

class MovieActionButtons extends StatelessWidget {
  final VoidCallback onWatchlistTap;
  final VoidCallback onLikeTap;
  final VoidCallback onReportTap;

  const MovieActionButtons({
    super.key,
    required this.onWatchlistTap,
    required this.onLikeTap,
    required this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          
          if (isSmallScreen) {
            return Column(
              children: [
                _buildWatchlistBtn(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildLikeBtn()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildReportBtn()),
                  ],
                ),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(child: _buildWatchlistBtn()),
                const SizedBox(width: 16),
                Expanded(child: _buildLikeBtn()),
                const SizedBox(width: 16),
                Expanded(child: _buildReportBtn()),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildWatchlistBtn() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF08DA5), // coral-pink
            Color(0xFFE8879F), // tertiary-container
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF08DA5).withOpacity(0.3),
            blurRadius: 20,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onWatchlistTap,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark, color: Color(0xFF681F36)), // on-tertiary-container
              SizedBox(width: 8),
              Text(
                'Add to Watchlist',
                style: TextStyle(
                  color: Color(0xFF681F36),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLikeBtn() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0x3329B5B5), // primary-container/20
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x4D5AD9D9)), // primary/30
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onLikeTap,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: Color(0xFF5AD9D9)),
              SizedBox(width: 8),
              Text(
                'Like',
                style: TextStyle(
                  color: Color(0xFF5AD9D9),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportBtn() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0x66193846), // surface-variant/40
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x4D3C4949)), // outline-variant/30
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onReportTap,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.report, color: Color(0xFFBCC9C8)),
              SizedBox(width: 8),
              Text(
                'Report',
                style: TextStyle(
                  color: Color(0xFFBCC9C8),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
