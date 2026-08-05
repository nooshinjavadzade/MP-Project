import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/models/auth/user.dart';
import 'package:movie_tracker_app/models/common/media_base.dart';
import 'package:movie_tracker_app/models/user_content/rating_response.dart';
import 'package:movie_tracker_app/models/user_content/review_response.dart';
import 'package:movie_tracker_app/presenters/profile/profile_presenter.dart';
import 'package:movie_tracker_app/services/api/profile_service.dart';

class FakeProfileService implements ProfileService {
  bool shouldThrowError = false;
  final DateTime _dummyDate = DateTime(2026, 1, 1);

  @override
  Future<User> getProfile() async {
    if (shouldThrowError) throw Exception('Get profile failed');
    return User(
      id: 1,
      username: 'johndoe',
      email: 'john@example.com',
      fullName: 'John Doe',
      createdAt: _dummyDate,
    );
  }

  @override
  Future<User> updateProfile({String? fullName, String? bio, String? avatarUrl}) async {
    if (shouldThrowError) throw Exception('Update profile failed');
    return User(
      id: 1,
      username: 'johndoe',
      email: 'john@example.com',
      fullName: fullName,
      bio: bio,
      avatarUrl: avatarUrl,
      createdAt: _dummyDate,
    );
  }

  @override
  Future<List<MediaBase>> getLikedMedia({int page = 1, int perPage = 20}) async {
    if (shouldThrowError) throw Exception('Get liked media failed');
    return [];
  }

  @override
  Future<List<RatingResponse>> getRatings({int page = 1, int perPage = 20}) async {
    if (shouldThrowError) throw Exception('Get ratings failed');
    return [
      RatingResponse(
        id: 1,
        mediaId: 100,
        userId: 1,
        rating: 9.0,
        ratedAt: _dummyDate,
      ),
    ];
  }

  @override
  Future<List<ReviewResponse>> getReviews({int page = 1, int perPage = 20}) async {
    if (shouldThrowError) throw Exception('Get reviews failed');
    return [
      ReviewResponse(
        id: 1,
        mediaId: 100,
        userId: 1,
        review: 'Great movie!',
        containsSpoiler: false,
        createdAt: _dummyDate,
      ),
    ];
  }

  @override
  Future<ReviewResponse> updateReview({
    required int reviewId,
    String? review,
    bool? containsSpoiler,
  }) async {
    if (shouldThrowError) throw Exception('Update review failed');
    return ReviewResponse(
      id: reviewId,
      mediaId: 100,
      userId: 1,
      review: review ?? 'Updated review text',
      containsSpoiler: containsSpoiler ?? false,
      createdAt: _dummyDate,
    );
  }

  @override
  Future<void> deleteReview(int reviewId) async {
    if (shouldThrowError) throw Exception('Delete review failed');
  }
}

void main() {
  late FakeProfileService fakeService;
  late ProfilePresenter presenter;

  setUp(() {
    fakeService = FakeProfileService();
    presenter = ProfilePresenter(fakeService);
  });

  group('ProfilePresenter Tests', () {
    test('getProfile updates user state', () async {
      await presenter.getProfile();

      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);
      expect(presenter.user, isNotNull);
      expect(presenter.user?.username, 'johndoe');
    });

    test('updateProfile updates user info', () async {
      await presenter.updateProfile(fullName: 'Jane Doe');

      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);
      expect(presenter.user?.fullName, 'Jane Doe');
    });

    test('getRatings populates ratings list', () async {
      await presenter.getRatings();

      expect(presenter.isLoading, false);
      expect(presenter.ratings.length, 1);
      expect(presenter.ratings.first.rating, 9.0);
    });

    test('getReviews populates reviews list', () async {
      await presenter.getReviews();

      expect(presenter.isLoading, false);
      expect(presenter.reviews.length, 1);
      expect(presenter.reviews.first.review, 'Great movie!');
    });

    test('updateReview populates updatedReview property', () async {
      await presenter.updateReview(reviewId: 5, review: 'New text');

      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);
      expect(presenter.updatedReview?.id, 5);
      expect(presenter.updatedReview?.review, 'New text');
    });

    test('deleteReview completes without error', () async {
      await presenter.deleteReview(5);

      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);
    });

    test('profile fetch failure sets errorMessage', () async {
      fakeService.shouldThrowError = true;

      await presenter.getProfile();

      expect(presenter.isLoading, false);
      expect(presenter.user, isNull);
      expect(presenter.errorMessage, contains('Get profile failed'));
    });
  });
}