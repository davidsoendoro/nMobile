import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../components/button/button_icon.dart';
import '../../generated/l10n.dart';
import '../../theme/theme.dart';
import '../../utils/assets.dart';

class Nav extends StatefulWidget {
  PageController controller;
  List<Widget> screens;
  int currentIndex = 0;

  Nav({
    this.screens,
    this.controller,
    this.currentIndex,
  });

  @override
  _NavState createState() => new _NavState();
}

class _NavState extends State<Nav> {
  void _onItemTapped(int index) {
    setState(() {
      widget.currentIndex = index;
      widget.controller.jumpToPage(index);
    });

  }

  @override
  Widget build(BuildContext context) {
    S _localizations = S.of(context);
    Color _color = Theme.of(context).unselectedWidgetColor;
    Color _selectedColor = DefaultTheme.primaryColor;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: DefaultTheme.backgroundColor2)],
        color: DefaultTheme.backgroundLightColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        minimum: EdgeInsets.only(bottom: 8, top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ButtonIcon(
              icon: assetIcon('chat', color: widget.currentIndex == 0 ? _selectedColor : _color),
              text: _localizations.menu_chat,
              height: 60,
              fontColor: widget.currentIndex == 0 ? _selectedColor : _color,
              onPressed: () => _onItemTapped(0),
            ),
            ButtonIcon(
              icon: assetIcon('wallet', color: widget.currentIndex == 1 ? _selectedColor : _color),
              text: _localizations.menu_wallet,
              height: 60,
              fontColor: widget.currentIndex == 1 ? _selectedColor : _color,
              onPressed: () => _onItemTapped(1),
            ),
            ButtonIcon(
              icon: assetIcon('settings', color: widget.currentIndex == 2 ? _selectedColor : _color),
              text: _localizations.menu_settings,
              height: 60,
              fontColor: widget.currentIndex == 2 ? _selectedColor : _color,
              onPressed: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
    );
  }
}
