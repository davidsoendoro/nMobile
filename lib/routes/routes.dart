import 'home.dart' as home;
import 'wallet.dart' as wallet;
import 'chat.dart' as chat;
import 'settings.dart' as settings;

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../app.dart';
import '../common/application.dart';

Map<String, WidgetBuilder> routes = {
  AppScreen.routeName: (BuildContext context) => AppScreen(),
};

GetIt locator = GetIt.instance;
Application app = locator.get<Application>();

init() {
  app.registerRoutes(routes);
  home.init();
  wallet.init();
  chat.init();
  settings.init();
}
