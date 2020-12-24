import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nmobile/screens/wallet/nkn_wallet_export.dart';
import 'package:nmobile/screens/wallet/send_erc_20.dart';
import 'package:nmobile/screens/wallet/send_nkn.dart';

import '../common/application.dart';
import '../screens/wallet/wallet.dart';
import '../screens/wallet/create_nkn_wallet.dart';
import '../screens/wallet/create_eth_wallet.dart';
import '../screens/wallet/import_nkn_eth_wallet.dart';
import '../screens/wallet/nkn_wallet_detail.dart';
import '../screens/wallet/recieve_nkn.dart';

Map<String, WidgetBuilder> routes = {
  WalletScreen.routeName: (BuildContext context) => WalletScreen(),
  CreateNknWalletScreen.routeName: (BuildContext context) => CreateNknWalletScreen(),
  CreateEthWalletScreen.routeName: (BuildContext context) => CreateEthWalletScreen(),
  NknWalletDetailScreen.routeName: (BuildContext context, {arguments}) => NknWalletDetailScreen(arguments: arguments),
  ImportWalletScreen.routeName: (BuildContext context, {arguments}) => ImportWalletScreen(arguments: arguments),
  ReceiveNknScreen.routeName: (BuildContext context, {arguments}) => ReceiveNknScreen(arguments: arguments),
  SendNknScreen.routeName: (BuildContext context, {arguments}) => SendNknScreen(arguments: arguments),
  SendErc20Screen.routeName: (BuildContext context, {arguments}) => SendErc20Screen(arguments: arguments),
  NknWalletExportScreen.routeName: (BuildContext context, {arguments}) => NknWalletExportScreen(arguments: arguments),
};

GetIt locator = GetIt.instance;
Application app = locator.get<Application>();

init() {
  app.registerRoutes(routes);
}
