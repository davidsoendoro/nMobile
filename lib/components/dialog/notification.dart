import 'package:bot_toast/bot_toast.dart';
import 'package:bot_toast/src/toast_widget/animation.dart';
import 'package:bot_toast/src/toast_widget/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nmobile/theme/theme.dart';

class NotificationDialog extends StatefulWidget {
  @override
  _NotificationDialogState createState() => _NotificationDialogState();
  BuildContext context;

  NotificationDialog.of(this.context);

  Color color;
  Widget icon;
  String title;
  String content;
  double height;
  CancelFunc cancelFunc;

  CancelFunc show({
    Color color,
    Widget icon,
    String title,
    String content,
    double height = 143,
  }) {
    this.color = color;
    this.icon = icon;
    this.title = title;
    this.content = content;
    this.height = height;
    return BotToast.showAnimationWidget(
        crossPage: true,
        allowClick: true,
        clickClose: false,
        ignoreContentClick: false,
        onlyOne: true,
        duration: const Duration(seconds: 6),
        animationDuration: const Duration(milliseconds: 256),
        wrapToastAnimation: (controller, cancel, child) {
          final anim = notificationAnimation(controller, cancel, child);
          if (anim != null) {
            child = anim;
          }
          child = Align(alignment: Alignment.topCenter, child: child);
          return child;
        },
        toastBuilder: (CancelFunc cancelFunc) {
          this.cancelFunc = cancelFunc;
          return NotificationToast(
            child: this,
            dismissDirections: const [DismissDirection.horizontal, DismissDirection.up],
            slideOffFunc: cancelFunc,
          );
        },
        groupKey: BotToast.notificationKey);
  }
}

class _NotificationDialogState extends State<NotificationDialog> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.all(0),
      height: 140,
      decoration: BoxDecoration(color: widget.color ?? DefaultTheme.primaryColor),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 24, top: 3, right: 6, bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: (widget.icon ?? SvgPicture.asset('assets/icons/check.svg', color: DefaultTheme.backgroundLightColor)),
              ),
              _buildText(context),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: SvgPicture.asset('assets/icons/close.svg', color: DefaultTheme.backgroundLightColor, width: 12, height: 12),
                  ),
                ),
                onTap: widget.cancelFunc,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 14),
            child: Text(
              widget.title,
              style: TextStyle(fontSize: DefaultTheme.h4FontSize, fontWeight: FontWeight.bold, color: DefaultTheme.backgroundLightColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Text(
              widget.content,
              style: TextStyle(fontSize: DefaultTheme.bodySmallFontSize, color: DefaultTheme.backgroundLightColor),
            ),
          ),
        ],
      ),
    );
  }
}
