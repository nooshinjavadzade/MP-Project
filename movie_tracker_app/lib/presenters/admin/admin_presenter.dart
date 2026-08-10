import 'package:flutter/foundation.dart';
import '../../models/admin.dart';
import '../../services/api/admin_service.dart';
import 'i_admin_presenter.dart';

class AdminPresenter extends ChangeNotifier implements IAdminPresenter {
  final AdminService _adminService;

  bool _isLoading = false;
  String? _errorMessage;

  AdminUserListResponse? _userListResponse;
  AdminUserResponse? _updatedUserResponse;
  AdminReviewListResponse? _reviewListResponse;
  AdminReportListResponse? _reportListResponse;
  AdminReportResponse? _updatedReportResponse;
  CachedMediaListResponse? _cachedMediaListResponse;
  CachedMediaResponse? _refreshedMediaResponse;
  AdminStats? _stats;
  AdminActionResponse? _lastActionResponse;

  AdminPresenter(this._adminService);

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  AdminUserListResponse? get userListResponse => _userListResponse;

  @override
  AdminUserResponse? get updatedUserResponse => _updatedUserResponse;

  @override
  AdminReviewListResponse? get reviewListResponse => _reviewListResponse;

  @override
  AdminReportListResponse? get reportListResponse => _reportListResponse;

  @override
  AdminReportResponse? get updatedReportResponse => _updatedReportResponse;

  @override
  CachedMediaListResponse? get cachedMediaListResponse => _cachedMediaListResponse;

  @override
  CachedMediaResponse? get refreshedMediaResponse => _refreshedMediaResponse;

  @override
  AdminStats? get stats => _stats;

  @override
  AdminActionResponse? get lastActionResponse => _lastActionResponse;

  @override
  Future<void> getUsers({int page = 1, int perPage = 20}) async {
    _setLoading(true);
    try {
      _userListResponse = await _adminService.getUsers(
        page: page,
        perPage: perPage,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> updateUser(int userId, AdminUserUpdate request) async {
    _setLoading(true);
    try {
      _updatedUserResponse = await _adminService.updateUser(
        userId: userId,
        request: request,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> deleteUser(int userId) async {
    _setLoading(true);
    try {
      _lastActionResponse = await _adminService.deleteUser(userId);
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
      _reviewListResponse = await _adminService.getReviews(
        page: page,
        perPage: perPage,
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
      _lastActionResponse = await _adminService.deleteReview(reviewId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getReports({int page = 1, int perPage = 20}) async {
    _setLoading(true);
    try {
      _reportListResponse = await _adminService.getReports(
        page: page,
        perPage: perPage,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> updateReport(int reportId, AdminReportUpdate request) async {
    _setLoading(true);
    try {
      _updatedReportResponse = await _adminService.updateReport(
        reportId: reportId,
        request: request,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getCachedMedia({int page = 1, int perPage = 20}) async {
    _setLoading(true);
    try {
      _cachedMediaListResponse = await _adminService.getCachedMedia(
        page: page,
        perPage: perPage,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> refreshMedia(int mediaId) async {
    _setLoading(true);
    try {
      _refreshedMediaResponse = await _adminService.refreshMedia(mediaId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> deleteCachedMedia(int mediaId) async {
    _setLoading(true);
    try {
      _lastActionResponse = await _adminService.deleteCachedMedia(mediaId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getStats() async {
    _setLoading(true);
    try {
      _stats = await _adminService.getStats();
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