import 'package:flutter/material.dart';
import 'package:nmobile/generated/l10n.dart';
import 'package:nmobile/theme/theme.dart';

class SimpleConfirm {
  final BuildContext context;
  final String title;
  final String content;
  final String buttonText;
  final Color buttonColor;
  final ValueChanged<bool> callback;

  SimpleConfirm({@required this.context, this.title, @required this.content, this.callback, this.buttonText, this.buttonColor});

  Future<void> show() {
    S _localizations = S.of(context);
    String title = this.title;
    String buttonText = this.buttonText;
    if (title == null || title.isEmpty) title = _localizations.tip;
    if (buttonText == null || buttonText.isEmpty) buttonText = _localizations.ok;
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title, style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
            content: Text(content, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            actions: <Widget>[
              FlatButton(
                child: Text(_localizations.cancel.toUpperCase(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DefaultTheme.fontColor2)),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (callback != null) callback(false);
                },
              ),
              FlatButton(
                child: Text(buttonText.toUpperCase(), style: TextStyle(color: buttonColor, fontSize: 14, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (callback != null) callback(true);
                },
              )
            ],
          );
        });
  }
}
