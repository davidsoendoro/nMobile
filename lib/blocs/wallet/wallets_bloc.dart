import 'package:bloc/bloc.dart';
import 'package:nmobile/blocs/wallet/wallets_event.dart';
import 'package:nmobile/blocs/wallet/wallets_state.dart';
import 'package:nmobile/schemas/wallet.dart';
import 'package:nmobile/storages/wallet.dart';

class WalletsBloc extends Bloc<WalletsEvent, WalletsState> {
  WalletsBloc() : super(WalletsLoading());

  final WalletStorage _walletStorage = WalletStorage();

  @override
  Stream<WalletsState> mapEventToState(WalletsEvent event) async* {
    if (event is LoadWallets) {
      yield* _mapLoadWalletsToState();
    } else if (event is AddWallet) {
      yield* _mapAddWalletToState(event);
    } else if (event is DeleteWallet) {
      yield* _mapDeleteWalletToState(event);
    } else if (event is UpdateWallet) {
      yield* _mapUpdateWalletToState(event);
    } else if (event is ReLoadWallets) {
      yield* _mapReloadWalletToState();
    } else if (event is UpdateWalletBackedUp) {
      yield* _setWalletBackedUp(event);
    }
  }

  Stream<WalletsState> _mapLoadWalletsToState() async* {
    var wallets = await _walletStorage.getAllWallets();
    yield WalletsLoaded(wallets);
  }

  Stream<WalletsState> _mapReloadWalletToState() async* {
    yield WalletsLoading();
    if (state is WalletsLoaded) {
      final List<WalletSchema> list = List.from((state as WalletsLoaded).wallets);
      yield WalletsLoaded(list);
    }
  }

  Stream<WalletsState> _mapAddWalletToState(AddWallet event) async* {
    if (state is WalletsLoaded) {
      yield WalletsLoading();
      final List<WalletSchema> list = List.from((state as WalletsLoaded).wallets);
      int index = list.indexWhere((w) => w.address == event.wallet.address);
      if (index > -1) {
        list[index] = event.wallet;
      } else {
        list.add(event.wallet);
      }
      yield WalletsLoaded(list);
      _walletStorage.addWallet(event.wallet, event.keystore);
    }
  }

  Stream<WalletsState> _mapUpdateWalletToState(UpdateWallet event) async* {
    if (state is WalletsLoaded) {
      final List<WalletSchema> list = List.from((state as WalletsLoaded).wallets);
      int index = list.indexOf(event.wallet);
      if (index >= 0) {
        list[index] = event.wallet;
        _walletStorage.setWallet(index, event.wallet);
      }
      yield* _mapReloadWalletToState();
    }
  }

  Stream<WalletsState> _mapDeleteWalletToState(DeleteWallet event) async* {
    if (state is WalletsLoaded) {
      yield WalletsLoading();
      final List<WalletSchema> list = List.from((state as WalletsLoaded).wallets);
      int index = list.indexOf(event.wallet);
      list.removeAt(index);
      yield WalletsLoaded(list);
      _walletStorage.deleteWallet(index, event.wallet);
    }
  }

  Stream<WalletsState> _setWalletBackedUp(UpdateWalletBackedUp event) async* {
    final address = event.address;
    final List<WalletSchema> list = List.from((state as WalletsLoaded).wallets);
    final wallet = list.firstWhere((w) => w.address == address, orElse: () => null);
    if (wallet != null) {
      int index = list.indexOf(wallet);
      wallet.isBackedUp = true;
      await _walletStorage.setWallet(index, wallet);
    }
    yield* _mapReloadWalletToState();
  }
}
