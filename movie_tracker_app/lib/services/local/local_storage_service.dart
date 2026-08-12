import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/auth/profile_response.dart';
import '../../models/common/top_media_item.dart';
import '../../models/movie/movie_details.dart';
import '../../models/series/series_details.dart';
import '../../models/user_content/personal_list.dart';

class LocalStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DefaultCacheManager _cacheManager = DefaultCacheManager();
  SharedPreferences? _prefs;

  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyTokenExpiry = 'token_expiry_timestamp';
  static const String _keyLoginTimestamp = 'login_timestamp';
  static const String _keyBiometricEnabled = 'biometric_enabled';

  static const String _keyUserProfile = 'cached_user_profile';
  static const String _keyUserStats = 'cached_user_stats';
  static const String _keyPersonalLists = 'cached_personal_lists';
  static const String _keySearchHistory = 'cached_search_history';
  static const String _keyPendingActions = 'cached_pending_actions';
  static const String _keyGenres = 'cached_genres';
  static const String _keyUserRatings = 'cached_user_ratings';
  static const String _keyHomeSectionKeys = 'cached_home_section_keys';

  static const String _keyMoviePrefix = 'cached_movie_';
  static const String _keySeriesPrefix = 'cached_series_';
  static const String _keyReviewsPrefix = 'cached_reviews_';
  static const String _keyWatchedEpisodesPrefix = 'cached_watched_episodes_';
  static const String _keyMediaWatchStatusPrefix = 'cached_watch_status_';
  static const String _keySeasonEpisodesPrefix = 'cached_season_episodes_';

  static const String _keyMovieCacheKeys = 'tracked_movie_cache_keys';
  static const String _keySeriesCacheKeys = 'tracked_series_cache_keys';
  static const int _maxMediaCacheEntries = 200;

  static const Duration _defaultTtl = Duration(hours: 24);

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _instance {
    if (_prefs == null) {
      throw StateError('LocalStorageService must be initialized by calling init() first.');
    }
    return _prefs!;
  }

  Future<void> _setTimestamp(String key) async {
    await _instance.setInt('${key}_ts', DateTime.now().millisecondsSinceEpoch);
  }

  bool _isCacheValid(String key, {Duration ttl = _defaultTtl}) {
    final ts = _instance.getInt('${key}_ts');
    if (ts == null) return false;
    final cacheDate = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(cacheDate) < ttl;
  }

  Future<void> _trackMediaCacheKey(String trackerKey, String cacheKey) async {
    final trackedKeys = _instance.getStringList(trackerKey) ?? [];
    trackedKeys.remove(cacheKey);
    trackedKeys.add(cacheKey);
    if (trackedKeys.length > _maxMediaCacheEntries) {
      final overflow = trackedKeys.length - _maxMediaCacheEntries;
      final evicted = trackedKeys.sublist(0, overflow);
      for (final key in evicted) {
        await _instance.remove(key);
        await _instance.remove('${key}_ts');
      }
      trackedKeys.removeRange(0, overflow);
    }
    await _instance.setStringList(trackerKey, trackedKeys);
  }

  Future<void> saveAuthToken(String token, {int? expiresInSeconds}) async {
    await _secureStorage.write(key: _keyAuthToken, value: token);
    if (expiresInSeconds != null) {
      final expiryTime = DateTime.now().add(Duration(seconds: expiresInSeconds)).millisecondsSinceEpoch;
      await _instance.setInt(_keyTokenExpiry, expiryTime);
    } else {
      await _instance.remove(_keyTokenExpiry);
    }
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _keyAuthToken);
  }

  Future<bool> isTokenExpired() async {
    final expiry = _instance.getInt(_keyTokenExpiry);
    if (expiry == null) return true;
    return DateTime.now().millisecondsSinceEpoch >= expiry;
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _keyAuthToken);
    await _secureStorage.delete(key: _keyRefreshToken);
    await _instance.remove(_keyTokenExpiry);
  }

  Future<void> saveLoginTimestamp() async {
    await _instance.setInt(_keyLoginTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  Future<int?> getLoginTimestamp() async {
    return _instance.getInt(_keyLoginTimestamp);
  }

  Future<bool> isSessionValid() async {
    final timestamp = await getLoginTimestamp();
    if (timestamp == null) return false;

    final loginDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(loginDate).inDays < 30;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _instance.setBool(_keyBiometricEnabled, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    return _instance.getBool(_keyBiometricEnabled) ?? false;
  }

  Future<void> saveUserProfile(ProfileResponse profile) async {
    await _instance.setString(_keyUserProfile, jsonEncode(profile.toJson()));
    await _setTimestamp(_keyUserProfile);
  }

  ProfileResponse? getUserProfile({bool checkTtl = true, Duration ttl = _defaultTtl}) {
    if (checkTtl && !_isCacheValid(_keyUserProfile, ttl: ttl)) return null;
    final str = _instance.getString(_keyUserProfile);
    if (str == null) return null;
    try {
      return ProfileResponse.fromJson(jsonDecode(str));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserStats(ProfileStats stats) async {
    await _instance.setString(_keyUserStats, jsonEncode(stats.toJson()));
    await _setTimestamp(_keyUserStats);
  }

  ProfileStats? getUserStats({bool checkTtl = true, Duration ttl = _defaultTtl}) {
    if (checkTtl && !_isCacheValid(_keyUserStats, ttl: ttl)) return null;
    final str = _instance.getString(_keyUserStats);
    if (str == null) return null;
    try {
      return ProfileStats.fromJson(jsonDecode(str));
    } catch (_) {
      return null;
    }
  }

  Future<void> invalidateUserStats() async {
    await _instance.remove(_keyUserStats);
    await _instance.remove('${_keyUserStats}_ts');
  }

  Future<void> savePersonalLists(List<PersonalListWithItems> lists) async {
    final jsonList = lists.map((e) => e.toJson()).toList();
    await _instance.setString(_keyPersonalLists, jsonEncode(jsonList));
    await _setTimestamp(_keyPersonalLists);
  }

  List<PersonalListWithItems> getPersonalLists({bool checkTtl = true, Duration ttl = _defaultTtl}) {
    if (checkTtl && !_isCacheValid(_keyPersonalLists, ttl: ttl)) return [];
    final str = _instance.getString(_keyPersonalLists);
    if (str == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(str);
      return jsonList
          .map((e) => PersonalListWithItems.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveGenres(List<String> genres) async {
    await _instance.setStringList(_keyGenres, genres);
    await _setTimestamp(_keyGenres);
  }

  List<String> getGenres({bool checkTtl = true, Duration ttl = const Duration(days: 7)}) {
    if (checkTtl && !_isCacheValid(_keyGenres, ttl: ttl)) return [];
    return _instance.getStringList(_keyGenres) ?? [];
  }

  Future<void> saveHomeSection(String sectionKey, List<TopMediaItem> items) async {
    final jsonList = items.map((e) => e.toJson()).toList();
    await _instance.setString(sectionKey, jsonEncode(jsonList));
    await _setTimestamp(sectionKey);
    final trackedKeys = _instance.getStringList(_keyHomeSectionKeys) ?? [];
    if (!trackedKeys.contains(sectionKey)) {
      trackedKeys.add(sectionKey);
      await _instance.setStringList(_keyHomeSectionKeys, trackedKeys);
    }
  }

  List<TopMediaItem> getHomeSection(String sectionKey, {bool checkTtl = true, Duration ttl = _defaultTtl}) {
    if (checkTtl && !_isCacheValid(sectionKey, ttl: ttl)) return [];
    final str = _instance.getString(sectionKey);
    if (str == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(str);
      return jsonList
          .map((e) => TopMediaItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveMovieDetails(String movieId, MovieDetails details) async {
    final key = '$_keyMoviePrefix$movieId';
    await _instance.setString(key, jsonEncode(details.toJson()));
    await _setTimestamp(key);
    await _trackMediaCacheKey(_keyMovieCacheKeys, key);
  }

  MovieDetails? getMovieDetails(String movieId, {bool checkTtl = true, Duration ttl = const Duration(days: 7)}) {
    final key = '$_keyMoviePrefix$movieId';
    if (checkTtl && !_isCacheValid(key, ttl: ttl)) return null;
    final str = _instance.getString(key);
    if (str == null) return null;
    try {
      return MovieDetails.fromJson(jsonDecode(str));
    } catch (_) {
      return null;
    }
  }

  Future<void> invalidateMovieDetails(String movieId) async {
    final key = '$_keyMoviePrefix$movieId';
    await _instance.remove(key);
    await _instance.remove('${key}_ts');
    final trackedKeys = _instance.getStringList(_keyMovieCacheKeys) ?? [];
    trackedKeys.remove(key);
    await _instance.setStringList(_keyMovieCacheKeys, trackedKeys);
  }

  Future<void> saveSeriesDetails(String seriesId, SeriesDetails details) async {
    final key = '$_keySeriesPrefix$seriesId';
    await _instance.setString(key, jsonEncode(details.toJson()));
    await _setTimestamp(key);
    await _trackMediaCacheKey(_keySeriesCacheKeys, key);
  }

  SeriesDetails? getSeriesDetails(String seriesId, {bool checkTtl = true, Duration ttl = const Duration(days: 7)}) {
    final key = '$_keySeriesPrefix$seriesId';
    if (checkTtl && !_isCacheValid(key, ttl: ttl)) return null;
    final str = _instance.getString(key);
    if (str == null) return null;
    try {
      return SeriesDetails.fromJson(jsonDecode(str));
    } catch (_) {
      return null;
    }
  }

  Future<void> invalidateSeriesDetails(String seriesId) async {
    final key = '$_keySeriesPrefix$seriesId';
    await _instance.remove(key);
    await _instance.remove('${key}_ts');
    final trackedKeys = _instance.getStringList(_keySeriesCacheKeys) ?? [];
    trackedKeys.remove(key);
    await _instance.setStringList(_keySeriesCacheKeys, trackedKeys);
  }

  Future<void> saveSeasonEpisodes(String seriesId, int seasonNumber, List<Map<String, dynamic>> episodes) async {
    final key = '$_keySeasonEpisodesPrefix${seriesId}_$seasonNumber';
    await _instance.setString(key, jsonEncode(episodes));
    await _setTimestamp(key);
  }

  List<Map<String, dynamic>> getSeasonEpisodes(String seriesId, int seasonNumber,
      {bool checkTtl = true, Duration ttl = const Duration(days: 7)}) {
    final key = '$_keySeasonEpisodesPrefix${seriesId}_$seasonNumber';
    if (checkTtl && !_isCacheValid(key, ttl: ttl)) return [];
    final str = _instance.getString(key);
    if (str == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(str);
      return jsonList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> invalidateSeasonEpisodes(String seriesId, int seasonNumber) async {
    final key = '$_keySeasonEpisodesPrefix${seriesId}_$seasonNumber';
    await _instance.remove(key);
    await _instance.remove('${key}_ts');
  }

  Future<void> saveMediaReviews(String mediaId, List<Map<String, dynamic>> reviews) async {
    final key = '$_keyReviewsPrefix$mediaId';
    await _instance.setString(key, jsonEncode(reviews));
    await _setTimestamp(key);
  }

  List<Map<String, dynamic>> getMediaReviews(String mediaId, {bool checkTtl = true, Duration ttl = _defaultTtl}) {
    final key = '$_keyReviewsPrefix$mediaId';
    if (checkTtl && !_isCacheValid(key, ttl: ttl)) return [];
    final str = _instance.getString(key);
    if (str == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(str);
      return jsonList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> invalidateMediaReviews(String mediaId) async {
    final key = '$_keyReviewsPrefix$mediaId';
    await _instance.remove(key);
    await _instance.remove('${key}_ts');
  }

  Future<void> saveUserRatings(Map<String, double> ratings) async {
    await _instance.setString(_keyUserRatings, jsonEncode(ratings));
    await _setTimestamp(_keyUserRatings);
    await invalidateUserStats();
  }

  Map<String, double> getUserRatings({bool checkTtl = true, Duration ttl = _defaultTtl}) {
    if (checkTtl && !_isCacheValid(_keyUserRatings, ttl: ttl)) return {};
    final str = _instance.getString(_keyUserRatings);
    if (str == null) return {};
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(str);
      return jsonMap.map((key, value) => MapEntry(key, (value as num).toDouble()));
    } catch (_) {
      return {};
    }
  }

  Future<void> setMediaWatchStatus(String mediaId, String status) async {
    final key = '$_keyMediaWatchStatusPrefix$mediaId';
    await _instance.setString(key, status);
    await invalidateUserStats();
  }

  String? getMediaWatchStatus(String mediaId) {
    final key = '$_keyMediaWatchStatusPrefix$mediaId';
    return _instance.getString(key);
  }

  Future<void> setEpisodeWatched(String seriesId, String episodeId, bool isWatched) async {
    final key = '$_keyWatchedEpisodesPrefix$seriesId';
    final watchedList = List<String>.from(getWatchedEpisodes(seriesId));
    if (isWatched) {
      if (!watchedList.contains(episodeId)) watchedList.add(episodeId);
    } else {
      watchedList.remove(episodeId);
    }
    await _instance.setStringList(key, watchedList);
    await invalidateUserStats();
  }

  List<String> getWatchedEpisodes(String seriesId) {
    final key = '$_keyWatchedEpisodesPrefix$seriesId';
    final list = _instance.getStringList(key) ?? [];
    return List<String>.from(list);
  }

  Future<List<String>> getSearchHistory() async {
    return List<String>.from(_instance.getStringList(_keySearchHistory) ?? []);
  }

  Future<void> addSearchQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final history = await getSearchHistory();
    history.removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());
    history.insert(0, trimmed);
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }
    await _instance.setStringList(_keySearchHistory, history);
  }

  Future<void> removeSearchQuery(String query) async {
    final history = await getSearchHistory();
    history.removeWhere((item) => item.toLowerCase() == query.trim().toLowerCase());
    await _instance.setStringList(_keySearchHistory, history);
  }

  Future<void> clearSearchHistory() async {
    await _instance.remove(_keySearchHistory);
  }

  Future<void> addOrUpdatePendingAction(Map<String, dynamic> actionData) async {
    final actions = getPendingActions();
    final String targetId = actionData['target_id']?.toString() ?? '';
    final String actionType = actionData['action_type']?.toString() ?? '';

    if (targetId.isNotEmpty && actionType.isNotEmpty) {
      actions.removeWhere((item) =>
      item['target_id']?.toString() == targetId &&
          item['action_type']?.toString() == actionType);
    }

    final String actionId = '${DateTime.now().millisecondsSinceEpoch}_${actions.length}';
    final Map<String, dynamic> formattedAction = {
      'id': actionData['id'] ?? actionId,
      'timestamp': actionData['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      'status': actionData['status'] ?? 'pending',
      'retry_count': actionData['retry_count'] ?? 0,
      ...actionData,
    };
    actions.add(formattedAction);
    actions.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));
    await _instance.setString(_keyPendingActions, jsonEncode(actions));
  }

  List<Map<String, dynamic>> getPendingActions({String? actionType, String? status}) {
    final jsonString = _instance.getString(_keyPendingActions);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      var list = jsonList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (actionType != null) {
        list = list.where((item) => item['action_type'] == actionType).toList();
      }
      if (status != null) {
        list = list.where((item) => item['status'] == status).toList();
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> markPendingActionFailed(String actionId, {int maxRetries = 5}) async {
    final actions = getPendingActions();
    for (final action in actions) {
      if (action['id'] == actionId) {
        final retryCount = (action['retry_count'] as int? ?? 0) + 1;
        action['retry_count'] = retryCount;
        action['status'] = retryCount >= maxRetries ? 'failed' : 'pending';
      }
    }
    await _instance.setString(_keyPendingActions, jsonEncode(actions));
  }

  Future<void> markPendingActionSynced(String actionId) async {
    await removePendingAction(actionId);
  }

  Future<void> removePendingAction(String actionId) async {
    final actions = getPendingActions();
    actions.removeWhere((action) => action['id'] == actionId);
    await _instance.setString(_keyPendingActions, jsonEncode(actions));
  }

  Future<void> clearPendingActions() async {
    await _instance.remove(_keyPendingActions);
  }

  Future<void> prefetchImage(String imageUrl) async {
    if (imageUrl.trim().isEmpty) return;
    await _cacheManager.downloadFile(imageUrl);
  }

  Future<void> clearImageCache() async {
    await _cacheManager.emptyCache();
  }

  Future<void> clearExpiredMediaCache({Duration ttl = const Duration(days: 7)}) async {
    final keys = _instance.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyMoviePrefix) ||
          key.startsWith(_keySeriesPrefix) ||
          key.startsWith(_keyReviewsPrefix) ||
          key.startsWith(_keySeasonEpisodesPrefix)) {
        if (!key.endsWith('_ts') && !_isCacheValid(key, ttl: ttl)) {
          await _instance.remove(key);
          await _instance.remove('${key}_ts');
        }
      }
    }

    for (final trackerKey in [_keyMovieCacheKeys, _keySeriesCacheKeys, _keyHomeSectionKeys]) {
      final trackedKeys = _instance.getStringList(trackerKey) ?? [];
      final remainingKeys = <String>[];
      for (final key in trackedKeys) {
        if (!_isCacheValid(key, ttl: ttl)) {
          await _instance.remove(key);
          await _instance.remove('${key}_ts');
        } else {
          remainingKeys.add(key);
        }
      }
      await _instance.setStringList(trackerKey, remainingKeys);
    }
  }

  Future<void> clearSessionData() async {
    await clearTokens();
    await _instance.remove(_keyLoginTimestamp);
    await _instance.remove(_keyUserProfile);
    await _instance.remove(_keyUserStats);
    await _instance.remove(_keyPersonalLists);
    await _instance.remove(_keyPendingActions);
    await _instance.remove(_keyUserRatings);
    await _cacheManager.emptyCache();

    final keys = _instance.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyMoviePrefix) ||
          key.startsWith(_keySeriesPrefix) ||
          key.startsWith(_keyReviewsPrefix) ||
          key.startsWith(_keyWatchedEpisodesPrefix) ||
          key.startsWith(_keyMediaWatchStatusPrefix) ||
          key.startsWith(_keySeasonEpisodesPrefix)) {
        await _instance.remove(key);
      }
    }
    await _instance.remove(_keyMovieCacheKeys);
    await _instance.remove(_keySeriesCacheKeys);
  }

  Future<void> clearAllData() async {
    await _secureStorage.deleteAll();
    await _cacheManager.emptyCache();
    await _instance.clear();
  }
}