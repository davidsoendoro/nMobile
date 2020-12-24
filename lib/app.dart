import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nmobile/screens/chat/chat.dart';
import 'package:nmobile/screens/settings/settings.dart';
import 'package:nmobile/services/task_service.dart';

import 'blocs/wallet/wallets_bloc.dart';
import 'blocs/wallet/wallets_event.dart';
import 'common/application.dart';
import 'common/global.dart';
import 'components/footer/nav.dart';
import 'native/common.dart';
import 'screens/wallet/wallet.dart';

class AppScreen extends StatefulWidget {
  static const String routeName = '/';

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  GetIt locator = GetIt.instance;
  Application app;
  WalletsBloc _walletsBloc;
  PageController _pageController;
  int _currentIndex = 0;
  List<Widget> screens = <Widget>[
    ChatScreen(),
    WalletScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _walletsBloc = BlocProvider.of<WalletsBloc>(context);
    _walletsBloc.add(LoadWallets());
    app = locator.get<Application>();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // init
    Global.appContext = context;
    app.mounted();
    return WillPopScope(
      onWillPop: () async {
        await Common.backDesktop();
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (n) {
                setState(() {
                  _currentIndex = n;
                });
              },
              children: screens,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Nav(
                currentIndex: _currentIndex,
                screens: screens,
                controller: _pageController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
