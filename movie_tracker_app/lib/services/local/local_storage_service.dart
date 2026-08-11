import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyLoginTimestamp = 'login_timestamp';
  static const String _keyBiometricEnabled = 'biometric_enabled';

  Future<void> saveLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLoginTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  Future<int?> getLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLoginTimestamp);
  }

  Future<bool> isSessionValid() async {
    final timestamp = await getLoginTimestamp();
    if (timestamp == null) return false;

    final loginDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = DateTime.now().difference(loginDate);

    return difference.inDays < 30;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  Future<void> clearSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoginTimestamp);
  }
}