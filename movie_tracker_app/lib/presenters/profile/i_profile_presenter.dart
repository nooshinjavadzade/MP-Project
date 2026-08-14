import '../../models/auth/user.dart';
import '../../models/common/media_base.dart';
import '../../models/user_content/rating_response.dart';
import '../../models/user_content/review_response.dart';

abstract class IProfilePresenter {
  bool get isLoading;
  String? get errorMessage;

  User? get user;
  List<MediaBase> get likedMedia;
  List<RatingResponse> get ratings;
  List<ReviewResponse> get reviews;
  ReviewResponse? get updatedReview;

  Future<void> getProfile();
  Future<void> getProfileFull({bool checkTtl = true});
  Future<void> updateProfile({String? fullName, String? bio, String? avatarUrl});
  Future<void> getLikedMedia({int page = 1, int perPage = 20});
  Future<void> getRatings({int page = 1, int perPage = 20});
  Future<void> getReviews({int page = 1, int perPage = 20});
  Future<void> updateReview({required int reviewId, String? review, bool? containsSpoiler});
  Future<void> deleteReview(int reviewId);
}