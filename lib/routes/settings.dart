import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../screens/settings/advice_page.dart';
import '../screens/select.dart';
import '../common/application.dart';

Map<String, WidgetBuilder> routes = {
  SelectScreen.routeName: (BuildContext context) => SelectScreen(),
  AdvancePage.routeName: (BuildContext context) => AdvancePage(),
};

GetIt locator = GetIt.instance;
Application app = locator.get<Application>();

init() {
  app.registerRoutes(routes);
}
