import 'package:flutter/material.dart';
import 'package:nmobile/components/layout/header.dart';
import 'package:nmobile/components/tabs.dart';
import 'package:nmobile/generated/l10n.dart';

import 'package:nmobile/schemas/wallet.dart';
import 'package:nmobile/theme/theme.dart';

import 'import_keystore_nkn_eth_wallet.dart';
import 'import_seed_nkn_eth_wallet.dart';

class ImportWalletScreen extends StatefulWidget {
  static const String routeName = '/wallet/import_nkn_wallet';

  final arguments;
  WalletType type = WalletType.nkn;

  ImportWalletScreen({this.arguments}) {
    if (arguments != null) {
      type = arguments['type'];
    }
  }

  @override
  _ImportWalletScreenState createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    S _localizations = S.of(context);
    List<String> tabs = [_localizations.tab_keystore, _localizations.tab_seed];
    return Scaffold(
      appBar: Header(
        title: widget.type == WalletType.eth ? _localizations.import_ethereum_wallet : _localizations.import_nkn_wallet,
        backgroundColor: DefaultTheme.backgroundColor4,
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                child: Container(
                  constraints: BoxConstraints.expand(),
                  color: DefaultTheme.backgroundColor4,
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: DefaultTheme.backgroundLightColor,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                          ),
                          child: Flex(
                            direction: Axis.vertical,
                            children: <Widget>[
                              Expanded(
                                flex: 0,
                                child: Tabs(
                                  controller: _tabController,
                                  tabs: tabs,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 0.2),
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: <Widget>[
                                      ImportKeystoreWallet(type: widget.type),
                                      ImportSeedWallet(type: widget.type),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
