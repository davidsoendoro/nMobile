import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../common/application.dart';
import '../screens/chat/chat.dart';


Map<String, WidgetBuilder> routes = {
  ChatScreen.routeName: (BuildContext context) => ChatScreen(),
};

GetIt locator = GetIt.instance;
Application app = locator.get<Application>();

init() {
  app.registerRoutes(routes);
}
