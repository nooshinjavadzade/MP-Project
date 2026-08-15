import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presenters/admin/admin_presenter.dart';

class ManageReviewsScreen extends StatefulWidget {
  const ManageReviewsScreen({super.key});

  @override
  State<ManageReviewsScreen> createState() => _ManageReviewsScreenState();
}

class _ManageReviewsScreenState extends State<ManageReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPresenter>().getReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00161F),
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
                    color: const Color(0xFF3C4949).withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFBCC9C8)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'مدیریت نقد و بررسی‌ها',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5AD9D9),
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<AdminPresenter>(
        builder: (context, presenter, child) {
          if (presenter.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5AD9D9)));
          }

          if (presenter.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFFFB4AB),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'خطا در بارگذاری: ${presenter.errorMessage}',
                    style: const TextStyle(color: Color(0xFFFFB4AB)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => presenter.getReviews(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('تلاش مجدد'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5AD9D9),
                      side: const BorderSide(color: Color(0xFF5AD9D9)),
                    ),
                  ),
                ],
              ),
            );
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
                      'هیچ نقد و بررسی‌ای یافت نشد.',
                      style: TextStyle(color: Color(0xFFBCC9C8)),
                    ),
                  ),
                )
              else
                ...items.map((review) {
                  // راه‌حل موقت: چون بک‌اند فعلاً user/media رو nested
                  // برنمی‌گردونه، از userId/mediaId به‌عنوان fallback استفاده می‌کنیم
                  // تا وقتی بک‌اند درست شه.
                  final userName = review.user?.username ?? 'کاربر #${review.userId}';
                  final email = review.user?.email ?? '';
                  final mediaTitle = review.media?.title ?? 'رسانه #${review.mediaId}';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _ReviewCard(
                      userName: userName,
                      email: email,
                      mediaTitle: mediaTitle,
                      content: review.review,
                      containsSpoiler: review.containsSpoiler,
                      onDelete: () async {
                        await presenter.deleteReview(review.id);
                        if (presenter.errorMessage == null) {
                          await presenter.getReviews();
                        }
                      },
                    ),
                  );
                }).toList(),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String userName;
  final String email;
  final String mediaTitle;
  final String content;
  final bool containsSpoiler;
  final VoidCallback onDelete;

  const _ReviewCard({
    required this.userName,
    required this.email,
    required this.mediaTitle,
    required this.content,
    required this.containsSpoiler,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F5F66).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF869393).withOpacity(0.2),
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
                        color: Color(0xFF5AD9D9),
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: const Color(0xFFBCC9C8).withOpacity(0.8),
                        ),
                      ),
                    ],
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
              if (containsSpoiler)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB4AB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFFFB4AB).withOpacity(0.3)),
                  ),
                  child: const Text(
                    'اسپویلر',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFB4AB),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              height: 1.5,
              color: const Color(0xFFC7E7F8).withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text(
                'حذف',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFB4AB),
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
}