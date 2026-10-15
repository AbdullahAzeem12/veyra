import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthResult {
  final bool success;
  final String message;
  final List<BiometricType> availableTypes;

  const BiometricAuthResult({
    required this.success,
    required this.message,
    this.availableTypes = const [],
  });
}

/// Native Biometric Authentication service for physical Android & iOS devices.
/// Interfaces with local_auth and handles hardware permissions and error codes.
class VeyraBiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if the physical device supports biometric hardware and has biometrics enrolled.
  static Future<bool> isBiometricsSupported() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Lists available biometric sensors on the physical device (fingerprint, face, iris, etc.).
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Authenticates using the physical device biometric sensor (Fingerprint / Face ID).
  static Future<BiometricAuthResult> authenticate({
    String reason = 'Authenticate to access Veyra VIP privileges and confidential bookings',
  }) async {
    try {
      final isSupported = await isBiometricsSupported();
      if (!isSupported) {
        return const BiometricAuthResult(
          success: false,
          message: 'Biometric hardware sensor is not available on this device.',
        );
      }

      final available = await getAvailableBiometrics();

      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (authenticated) {
        return BiometricAuthResult(
          success: true,
          message: 'Biometric verified successfully! VIP clearance granted.',
          availableTypes: available,
        );
      } else {
        return BiometricAuthResult(
          success: false,
          message: 'Biometric authentication was cancelled or not recognized.',
          availableTypes: available,
        );
      }
    } on LocalAuthException catch (e) {
      String msg = 'Biometric error: ${e.description ?? e.code.name}';
      if (e.code == LocalAuthExceptionCode.noBiometricHardware ||
          e.code == LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable) {
        msg = 'Biometric sensor not available on this device or permission denied.';
      } else if (e.code == LocalAuthExceptionCode.noBiometricsEnrolled ||
          e.code == LocalAuthExceptionCode.noCredentialsSet) {
        msg = 'No fingerprints or facial data enrolled in device security settings.';
      } else if (e.code == LocalAuthExceptionCode.temporaryLockout ||
          e.code == LocalAuthExceptionCode.biometricLockout) {
        msg = 'Biometric sensor temporarily locked out due to too many failed attempts.';
      }
      return BiometricAuthResult(
        success: false,
        message: msg,
      );
    } on PlatformException catch (e) {
      String msg = 'Biometric error: ${e.message}';
      if (e.code == 'NotAvailable') {
        msg = 'Biometric sensor not available on this device or permission denied.';
      } else if (e.code == 'NotEnrolled') {
        msg = 'No fingerprints or facial data enrolled in device security settings.';
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        msg = 'Biometric sensor temporarily locked out due to too many failed attempts.';
      }
      return BiometricAuthResult(
        success: false,
        message: msg,
      );
    } catch (e) {
      return BiometricAuthResult(
        success: false,
        message: 'Authentication failed: $e',
      );
    }
  }
}
