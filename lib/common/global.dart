import 'dart:io';

import 'package:flutter/material.dart';

class Global{
  static bool get isRelease => const bool.fromEnvironment("dart.vm.product");
  static BuildContext appContext;
  static Directory applicationRootDirectory;
  static String version;
  static String build;
  static String get versionFormat => '${Global.version} + (Build ${Global.build})';
}