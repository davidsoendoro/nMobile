import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';
import 'package:nmobile/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

void copyAction(context, String content) {
  Clipboard.setData(ClipboardData(text: content));
  BotToast.showText(text: S.of(context).copy_success);
}

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceSafariVC: false);
  } else {
    throw 'Could not launch $url';
  }
}

Future<double> getTotalSizeOfCacheFile(final FileSystemEntity file) async {
  if (file is File) {
    int length = await file.length();
    return double.parse(length.toString());
  }
  if (file is Directory) {
    final List<FileSystemEntity> children = file.listSync();
    double total = 0;
    if (children != null)
      for (final FileSystemEntity child in children) {
        if (RegExp(r'[0-9a-f]{64}(/[^/]+)?$').hasMatch(child.path)) {
          total += await getTotalSizeOfCacheFile(child);
        }
      }
    return total;
  }
  return 0;
}

Future<void> clearCacheFile(final FileSystemEntity file) async {
  if (file is File) {
    file.deleteSync();
  }
  if (file is Directory) {
    final List<FileSystemEntity> children = file.listSync();
    if (children != null)
      for (final FileSystemEntity child in children) {
        if (RegExp(r'[0-9a-f]{64}(/[^/]+)?$').hasMatch(child.path)) {
          await clearCacheFile(child);
        }
      }
  }
}

Future<double> getTotalSizeOfDbFile(final FileSystemEntity file) async {
  if (file is File) {
    int length = await file.length();
    return double.parse(length.toString());
  }
  if (file is Directory) {
    final List<FileSystemEntity> children = file.listSync();
    double total = 0;
    if (children != null)
      for (final FileSystemEntity child in children) {
        if (RegExp(r'.*\.db$').hasMatch(child.path)) {
          total += await getTotalSizeOfCacheFile(child);
        }
      }
    return total;
  }
  return 0;
}

Future<void> clearDbFile(final FileSystemEntity file) async {
  if (file is File) {
    file.deleteSync();
  }
  if (file is Directory) {
    final List<FileSystemEntity> children = file.listSync();
    if (children != null)
      for (final FileSystemEntity child in children) {
        if (RegExp(r'.*\.db$').hasMatch(child.path)) {
          await clearDbFile(child);
        }
      }
  }
}
