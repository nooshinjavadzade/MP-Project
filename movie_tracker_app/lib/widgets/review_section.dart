import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../presenters/media/media_presenter.dart';
import '../../../../models/user_content/review_response.dart'; // 🔹 ایمپورت مدل ReviewResponse

class ReviewSection extends StatefulWidget {
  final int tmdbId;
  final String mediaType;

  const ReviewSection({
    super.key,
    required this.tmdbId,
    required this.mediaType,
  });

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final presenter = context.read<MediaPresenter>();
    await presenter.getReviews(widget.tmdbId.toString(), widget.mediaType);
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty && _rating == 0) return;

    setState(() => _isLoading = true);
    final presenter = context.read<MediaPresenter>();

    try {
      if (_rating > 0) {
        await presenter.rateMedia(
            widget.tmdbId.toString(), widget.mediaType, _rating.toDouble());
      }
      if (_reviewController.text.trim().isNotEmpty) {
        await presenter.createReview(
            widget.tmdbId.toString(), widget.mediaType, _reviewController.text.trim(), false);
      }

      _reviewController.clear();
      setState(() => _rating = 0);
      await _loadReviews();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildStar(int index) {
    bool isSelected = index < _rating;
    return GestureDetector(
      onTap: () {
        setState(() {
          _rating = index + 1;
        });
      },
      child: Icon(
        isSelected ? Icons.star : Icons.star_border,
        color: isSelected ? const Color(0xFFF08DA5) : const Color(0xFFBCC9C8).withOpacity(0.3),
        size: 24,
      ),
    );
  }

  Widget _buildReviewList(MediaPresenter presenter) {
    final List<ReviewResponse> reviews = presenter.reviews;
    if (reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Text(
            'هنوز نظری ثبت نشده. اولین نفر باشید!',
            style: TextStyle(color: Color(0xFFBCC9C8), fontFamily: 'Manrope'),
          ),
        ),
      );
    }

    return Column(
      children: reviews.map((review) {
        final String authorName = review.userName;
        final String content = review.review;
        final bool isSpoiler = review.containsSpoiler;

        return Container(
          padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0x333C4949)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        authorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      if (isSpoiler)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF08DA5).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'اسپویلر',
                            style: TextStyle(
                              color: Color(0xFFF08DA5),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: List.generate(5, (index) => const Icon(
                      Icons.star,
                      color: Color(0xFFF08DA5),
                      size: 14,
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: TextStyle(
                  color: const Color(0xFFBCC9C8).withOpacity(0.7),
                  fontSize: 14,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نظرات و امتیازات',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0x9900232F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x4D3C4949)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'به این اثر امتیاز دهید:',
                    style: TextStyle(
                      color: Color(0xFFBCC9C8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(5, _buildStar),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x66001F2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x4D3C4949)),
                ),
                child: TextField(
                  controller: _reviewController,
                  maxLines: 4,
                  style: const TextStyle(color: Color(0xFFC7E7F8), fontFamily: 'Manrope'),
                  decoration: InputDecoration(
                    hintText: 'نظر خود را بنویسید...',
                    hintStyle: TextStyle(
                      color: const Color(0xFFBCC9C8).withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF08DA5),
                    foregroundColor: const Color(0xFF3F0018),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF3F0018),
                    ),
                  )
                      : const Text(
                    'ارسال نظر',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Consumer<MediaPresenter>(
          builder: (context, presenter, _) {
            if (presenter.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF5AD9D9)));
            }
            return _buildReviewList(presenter);
          },
        ),
      ],
    );
  }
}