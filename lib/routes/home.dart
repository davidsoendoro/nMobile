import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../common/application.dart';
import '../screens/scanner.dart';


Map<String, WidgetBuilder> routes = {
  ScannerScreen.routeName: (BuildContext context) => ScannerScreen(),
};

GetIt locator = GetIt.instance;
Application app = locator.get<Application>();

init() {
  app.registerRoutes(routes);
}
