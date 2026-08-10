import '../../models/admin.dart';

abstract class IAdminPresenter {
  bool get isLoading;
  String? get errorMessage;

  AdminUserListResponse? get userListResponse;
  AdminUserResponse? get updatedUserResponse;
  AdminReviewListResponse? get reviewListResponse;
  AdminReportListResponse? get reportListResponse;
  AdminReportResponse? get updatedReportResponse;
  CachedMediaListResponse? get cachedMediaListResponse;
  CachedMediaResponse? get refreshedMediaResponse;
  AdminStats? get stats;
  AdminActionResponse? get lastActionResponse;

  Future<void> getUsers({int page = 1, int perPage = 20});
  Future<void> updateUser(int userId, AdminUserUpdate request);
  Future<void> deleteUser(int userId);

  Future<void> getReviews({int page = 1, int perPage = 20});
  Future<void> deleteReview(int reviewId);

  Future<void> getReports({int page = 1, int perPage = 20});
  Future<void> updateReport(int reportId, AdminReportUpdate request);

  Future<void> getCachedMedia({int page = 1, int perPage = 20});
  Future<void> refreshMedia(int mediaId);
  Future<void> deleteCachedMedia(int mediaId);

  Future<void> getStats();
}