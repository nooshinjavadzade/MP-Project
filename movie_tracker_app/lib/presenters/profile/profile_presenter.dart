import 'package:flutter/foundation.dart';
import '../../models/auth/user.dart';
import '../../models/common/media_base.dart';
import '../../models/user_content/rating_response.dart';
import '../../models/user_content/review_response.dart';
import '../../services/api/profile_service.dart';
import 'i_profile_presenter.dart';

class ProfilePresenter extends ChangeNotifier implements IProfilePresenter {
  final ProfileService _profileService;

  bool _isLoading = false;
  String? _errorMessage;

  User? _user;
  List<MediaBase> _likedMedia = [];
  List<RatingResponse> _ratings = [];
  List<ReviewResponse> _reviews = [];
  ReviewResponse? _updatedReview;

  ProfilePresenter(this._profileService);

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  User? get user => _user;

  @override
  List<MediaBase> get likedMedia => _likedMedia;

  @override
  List<RatingResponse> get ratings => _ratings;

  @override
  List<ReviewResponse> get reviews => _reviews;

  @override
  ReviewResponse? get updatedReview => _updatedReview;

  @override
  Future<void> getProfile() async {
    _setLoading(true);
    try {
      _user = await _profileService.getProfile();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> updateProfile({String? fullName, String? bio, String? avatarUrl}) async {
    _setLoading(true);
    try {
      _user = await _profileService.updateProfile(
        fullName: fullName,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getLikedMedia({int page = 1, int perPage = 20}) async {
    _setLoading(true);
    try {
      _likedMedia = await _profileService.getLikedMedia(page: page, perPage: perPage);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getRatings({int page = 1, int perPage = 20}) async {
    _setLoading(true);
    try {
      _ratings = await _profileService.getRatings(page: page, perPage: perPage);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getReviews({int page = 1, int perPage = 20}) async {
    _setLoading(true);
    try {
      _reviews = await _profileService.getReviews(page: page, perPage: perPage);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> updateReview({
    required int reviewId,
    String? review,
    bool? containsSpoiler,
  }) async {
    _setLoading(true);
    try {
      _updatedReview = await _profileService.updateReview(
        reviewId: reviewId,
        review: review,
        containsSpoiler: containsSpoiler,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> deleteReview(int reviewId) async {
    _setLoading(true);
    try {
      await _profileService.deleteReview(reviewId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}