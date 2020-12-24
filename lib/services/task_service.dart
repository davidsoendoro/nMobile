import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nkn_sdk_flutter/wallet.dart';
import 'package:nmobile/blocs/wallet/wallets_bloc.dart';
import 'package:nmobile/blocs/wallet/wallets_event.dart';
import 'package:nmobile/blocs/wallet/wallets_state.dart';
import 'package:nmobile/common/global.dart';
import 'package:nmobile/helpers/nkn_erc20.dart';
import 'package:nmobile/schemas/wallet.dart';

class TaskService {
  Dio dio = Dio();
  WalletsBloc _walletsBloc;
  EthErc20Client _erc20client;
  Timer _queryNknWalletBalanceTask;
  bool _isInit = false;

  install() {
    if (!_isInit) {
      _walletsBloc = BlocProvider.of<WalletsBloc>(Global.appContext);
      _erc20client = EthErc20Client();
      _queryNknWalletBalanceTask = Timer.periodic(Duration(seconds: 60), (timer) {
        queryNknWalletBalanceTask();
      });
      queryNknWalletBalanceTask();
      _isInit = true;
    }
  }

  uninstall (){
    _queryNknWalletBalanceTask?.cancel();
  }

  queryNknWalletBalanceTask() {
    var state = _walletsBloc.state;
    if (state is WalletsLoaded) {
      List<Future> futures = <Future>[];
      state.wallets.forEach((w) {
        if (w.type == WalletSchema.ETH_WALLET) {
          futures.add(_erc20client.getBalance(address: w.address).then((balance) {
            w.balanceEth = balance.ether;
            _walletsBloc.add(UpdateWallet(w));
          }));
          futures.add(_erc20client.getNknBalance(address: w.address).then((balance) {
            if (balance != null) {
              w.balance = balance.ether;
              _walletsBloc.add(UpdateWallet(w));
            }
          }));
        } else if(w.type == WalletSchema.NKN_WALLET) {
          futures.add(Wallet.getBalanceByAddr(w.address).then((balance) {
            w.balance = balance;
            _walletsBloc.add(UpdateWallet(w));
          }));
        }
      });
      Future.wait(futures).then((data) {
        _walletsBloc.add(ReLoadWallets());
      });
    }
  }

}
