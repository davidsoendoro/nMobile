import 'package:get_it/get_it.dart';
import 'package:nmobile/common/global.dart';
import 'package:nmobile/components/dialog/bottom.dart';
import 'package:nmobile/generated/l10n.dart';
import 'package:nmobile/services/local_authentication_service.dart';

import '../helpers/secure_storage.dart';
import '../helpers/local_storage.dart';
import '../schemas/wallet.dart';

class WalletStorage {
  static const String WALLET_KEY = 'WALLETS';
  static const String KEYSTORES_KEY = 'KEYSTORES';
  static const String PASSWORDS_KEY = 'PASSWORDS';

  final LocalStorage _localStorage = LocalStorage();
  final SecureStorage _secureStorage = SecureStorage();
  final GetIt _locator = GetIt.instance;

  Future<List<WalletSchema>> getAllWallets() async {
    var wallets = await _localStorage.getArray(WALLET_KEY);
    if (wallets == null) {
      return [];
    }
    final list = wallets.map((x) {
      var wallet = WalletSchema.fromMap(x);
      return wallet;
    }).toList();
    return list;
  }

  Future addWallet(WalletSchema wallet, String keystore) async {
    List<Future> futures = <Future>[];

    Map<String, dynamic> data = wallet.toMap();
    var wallets = await _localStorage.getArray(WALLET_KEY);
    int index = wallets?.indexWhere((x) => x['address'] == wallet.address) ?? -1;
    if (index < 0) {
      futures.add(_localStorage.addItem(WALLET_KEY, data));
    } else {
      futures.add(_localStorage.setItem(WALLET_KEY, index, data));
    }
    futures.add(_localStorage.set('$KEYSTORES_KEY:${wallet.address}', keystore));
    await Future.wait(futures);
  }

  Future setWallet(int n, WalletSchema wallet) async {
    List<Future> futures = <Future>[];
    Map<String, dynamic> data = wallet.toMap();
    futures.add(_localStorage.setItem(WALLET_KEY, n, data));
    await Future.wait(futures);
  }

  Future deleteWallet(int n, WalletSchema wallet) async {
    List<Future> futures = <Future>[];
    futures.add(_localStorage.removeItem(WALLET_KEY, n));
    await Future.wait(futures);
  }

  Future<String> getKeystore(String address) async {
    return await _localStorage.get('$KEYSTORES_KEY:$address');
  }

  Future<String> getPassword(String address) async {
    return await _secureStorage.get('$PASSWORDS_KEY:$address');
  }

  Future<String> _showAuthPasswordDialog(String reason) {
    return BottomDialog.of(Global.appContext).showInputPasswordDialog(title: S.of(Global.appContext).verify_wallet_password);
  }

  Future<String> authPassword(String address) async {
    LocalAuthenticationService _localAuth = _locator.get<LocalAuthenticationService>();
    if (_localAuth.isProtectionEnabled) {
      bool auth = await _localAuth.authenticate();
      if (auth) {
        String password = await getPassword(address);
        if (password == null) {
          return _showAuthPasswordDialog('no password');
        }
        return password;
      } else {
        return null;
      }
    } else {
      return _showAuthPasswordDialog('disabled');
    }
  }
}
