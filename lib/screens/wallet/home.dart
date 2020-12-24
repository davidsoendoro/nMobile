import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nmobile/blocs/wallet/wallets_bloc.dart';
import 'package:nmobile/blocs/wallet/wallets_state.dart';
import 'package:nmobile/common/global.dart';
import 'package:nmobile/components/dialog/select_wallet_type.dart';
import 'package:nmobile/components/label.dart';
import 'package:nmobile/components/layout/header.dart';
import 'package:nmobile/components/layout/layout.dart';
import 'package:nmobile/components/wallet/item.dart';
import 'package:nmobile/generated/l10n.dart';
import 'package:nmobile/schemas/wallet.dart';
import 'package:nmobile/screens/wallet/create_nkn_wallet.dart';
import 'package:nmobile/screens/wallet/import_nkn_eth_wallet.dart';
import 'package:nmobile/services/task_service.dart';
import 'package:nmobile/theme/theme.dart';
import 'package:nmobile/utils/assets.dart';

import 'create_eth_wallet.dart';

class WalletHome extends StatefulWidget {
  static const String routeName = '/wallet/home';

  @override
  _WalletHomeState createState() => _WalletHomeState();
}

class _WalletHomeState extends State<WalletHome> with SingleTickerProviderStateMixin {
  WalletsBloc _walletsBloc;
  StreamSubscription _walletSubscription;
  final GetIt locator = GetIt.instance;

  double _totalNkn = 0;
  bool _allBackedUp = true;

  @override
  void initState() {
    super.initState();

    locator<TaskService>().queryNknWalletBalanceTask();
    _walletsBloc = BlocProvider.of<WalletsBloc>(Global.appContext);
    _walletSubscription = _walletsBloc.listen((state) {
      if (state is WalletsLoaded) {
        _totalNkn = 0;
        _allBackedUp = true;
        state.wallets.forEach((w) => _totalNkn += w.balance ?? 0);
        state.wallets.forEach((w) {
          _allBackedUp = w.isBackedUp && _allBackedUp;
        });
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _walletSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    S _localizations = S.of(context);
    return Layout(
      headerColor: DefaultTheme.primaryColor,
      header: Header(
        backgroundColor: DefaultTheme.primaryColor,
        titleChild: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Label(
            _localizations.my_wallets,
            type: LabelType.h2,
          ),
        ),
        actions: [
          PopupMenuButton(
            icon: assetIcon('more', width: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onSelected: (int result) async {
              switch (result) {
                case 0:
                  final WalletType type = await SelectWalletTypeDialog.of(context).show();
                  if (type == WalletType.nkn) {
                    Navigator.of(context).pushNamed(CreateNknWalletScreen.routeName);
                  } else if (type == WalletType.eth) {
                    Navigator.of(context).pushNamed(CreateEthWalletScreen.routeName);
                  }
                  break;
                case 1:
                  final WalletType type = await SelectWalletTypeDialog.of(context).show();
                  if (type == WalletType.nkn) {
                    Navigator.of(context).pushNamed(ImportWalletScreen.routeName, arguments: {'type': type});
                  } else if (type == WalletType.eth) {
                    Navigator.of(context).pushNamed(ImportWalletScreen.routeName, arguments: {'type': type});
                  }

                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                value: 0,
                child: Label(
                  _localizations.no_wallet_create,
                  type: LabelType.display,
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Label(
                  _localizations.import_wallet,
                  type: LabelType.display,
                ),
              ),
            ],
          )
        ],
      ),
      child: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: DefaultTheme.backgroundColor1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: BlocBuilder<WalletsBloc, WalletsState>(
          builder: (context, state) {
            if (state is WalletsLoaded) {
              return ListView.builder(
                  padding: EdgeInsets.only(top: 32, bottom: DefaultTheme.bottomNavHeight),
                  itemCount: state.wallets.length,
                  itemBuilder: (context, index) {
                    WalletSchema w = state.wallets[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
                      child: WalletItem(schema: w, index: index, type: w.type == WalletSchema.NKN_WALLET ? WalletType.nkn : WalletType.eth),
                    );
                  });
            }
            return ListView();
          },
        ),
      ),
    );
  }
}
