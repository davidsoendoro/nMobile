import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nmobile/common/global.dart';
import 'package:nmobile/generated/l10n.dart';
import 'package:nmobile/utils/logger.dart';

class LocalAuthenticationService {

  // static Future<LocalAuthenticationService> get instance async {
  //   if (_instance == null)
  //     await _lock.synchronized(() async {
  //       if (_instance == null) {
  //         final ins = LocalAuthenticationService._();
  //         final localStorage = LocalStorage();
  //         ins.isProtectionEnabled = (await localStorage.get('${LocalStorage.SETTINGS_KEY}:${LocalStorage.AUTH_KEY}')) as bool ?? false;
  //         ins.authType = await ins.getAuthType();
  //         _instance = ins;
  //       }
  //     });
  //   return _instance;
  // }

  final _localAuth = LocalAuthentication();
  bool isProtectionEnabled = false;
  BiometricType authType;

  Future<BiometricType> getAuthType() async {
    try {
      List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.contains(BiometricType.face)) {
        return BiometricType.face;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return BiometricType.fingerprint;
      }
    } on PlatformException catch (e) {
      logger.e(e);
    } on MissingPluginException catch (e) {
      logger.e(e);
    } catch (e) {
      logger.e(e);
    }
    return null;
  }

  Future<bool> authenticate() async {
    if (isProtectionEnabled) {
      try {
        final success = await _localAuth.authenticateWithBiometrics(
          localizedReason: S.of(Global.appContext).authenticate_to_access,
          useErrorDialogs: false,
          stickyAuth: true,
        );

        return success;
      } on PlatformException catch (e) {
        logger.e(e);
      } on MissingPluginException catch (e) {
        logger.e(e);
      } catch (e) {
        logger.e(e);
      }
    }
    return false;
  }

  Future<bool> cancelAuthentication() {
    if (isProtectionEnabled) {
      return _localAuth.stopAuthentication();
    } else
      return Future.value(true);
  }

  Future<bool> hasBiometrics() async {
    bool canCheck = await _localAuth.canCheckBiometrics;
    if (canCheck) {
      List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.contains(BiometricType.face)) {
        return true;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return true;
      }
    }
    return false;
  }
}
