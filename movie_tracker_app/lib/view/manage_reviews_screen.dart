import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presenters/admin/admin_presenter.dart';
import '../../services/api/admin_service.dart';

class ManageReviewsScreen extends StatelessWidget {
  const ManageReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminPresenter(AdminService())..getReviews(),
      child: Scaffold(
        backgroundColor: const Color(0xFF00161F), // surface
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: const Color(0xFF00232F).withOpacity(0.6),
          elevation: 0,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF3C4949).withOpacity(0.2), // outline-variant
                    ),
                  ),
                ),
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFBCC9C8)), // on-surface-variant
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Manage Reviews',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5AD9D9), // primary
            ),
          ),
          centerTitle: false,
        ),
        body: Consumer<AdminPresenter>(
          builder: (context, presenter, child) {
            if (presenter.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF5AD9D9)));
            }
            
            final items = presenter.reviewListResponse?.items ?? [];

            return ListView(
              padding: const EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 32.0),
              children: [
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No reviews found.',
                        style: TextStyle(color: Color(0xFFBCC9C8)),
                      ),
                    ),
                  )
                else
                  ...items.map((review) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _ReviewCard(
                        userName: review.userName,
                        email: review.email,
                        mediaTitle: review.mediaTitle,
                        rating: review.rating,
                        content: review.content,
                        onDelete: () => presenter.deleteReview(review.id),
                      ),
                    );
                  }).toList(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String userName;
  final String email;
  final String mediaTitle;
  final double rating;
  final String content;
  final VoidCallback onDelete;

  const _ReviewCard({
    required this.userName,
    required this.email,
    required this.mediaTitle,
    required this.rating,
    required this.content,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F5F66).withOpacity(0.4), // glass-card bg
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF869393).withOpacity(0.2), // outline
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5AD9D9), // primary
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        color: const Color(0xFFBCC9C8).withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mediaTitle.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Color(0xFFBCC9C8),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStarRating(rating),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              height: 1.5,
              color: const Color(0xFFC7E7F8).withOpacity(0.9), // on-surface
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text(
                'DELETE',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFB4AB), // error
                backgroundColor: const Color(0xFFFFB4AB).withOpacity(0.1),
                side: BorderSide(color: const Color(0xFFFFB4AB).withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      IconData iconData = Icons.star_border;
      if (i <= rating) {
        iconData = Icons.star;
      } else if (i - 0.5 <= rating) {
        iconData = Icons.star_half;
      }

      stars.add(
        Icon(
          iconData,
          size: 24,
          color: const Color(0xFF5AD9D9), // primary
          shadows: [
            Shadow(
              color: const Color(0xFF29B5B5), // primary-container
              blurRadius: 8,
            ),
          ],
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }
}
