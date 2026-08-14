import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'local_storage_service.dart';

class BiometricService {
  final LocalAuthentication _auth;
  final LocalStorageService _localStorageService;

  BiometricService({
    LocalAuthentication? auth,
    LocalStorageService? localStorageService,
  })  : _auth = auth ?? LocalAuthentication(),
        _localStorageService = localStorageService ?? LocalStorageService();

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  Future<bool> isBiometricEnabled() async {
    return await _localStorageService.isBiometricEnabled();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _localStorageService.setBiometricEnabled(enabled);
  }

  Future<bool> authenticate({String localizedReason = 'Biometric Authentication'}) async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: false,
      );
    } on PlatformException {
      return false;
    }
  }
}