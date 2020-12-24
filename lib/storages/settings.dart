import '../helpers/secure_storage.dart';
import '../helpers/local_storage.dart';

class SettingsStorage {
  static const String SETTINGS_KEY = 'SETTINGS';
  static const String AUTH_KEY = 'auth';
  static const String LOCALE_KEY = 'locale';
  static const String LOCAL_NOTIFICATION_TYPE_KEY = 'local_notification_type';
  static const String DEBUG_KEY = 'debug';

  final LocalStorage _localStorage = LocalStorage();
  final SecureStorage _secureStorage = SecureStorage();


  Future getSettings(String key) async {
    return await _localStorage.get('$SETTINGS_KEY:$key');
  }

  Future setSettings(String key, val) async {
    return await _localStorage.set('$SETTINGS_KEY:$key', val);
  }
}
