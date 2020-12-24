import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nmobile/components/label.dart';
import 'package:nmobile/generated/l10n.dart';
import 'package:nmobile/helpers/format.dart';
import 'package:nmobile/schemas/wallet.dart';
import 'package:nmobile/screens/wallet/nkn_wallet_detail.dart';
import 'package:nmobile/theme/theme.dart';

class WalletItem extends StatefulWidget {
  final WalletSchema schema;
  final int index;
  final WalletType type;
  final GestureTapCallback onTap;

  WalletItem({this.schema, this.index, this.type = WalletType.nkn, this.onTap});

  @override
  _WalletItemState createState() => _WalletItemState();
}

class _WalletItemState extends State<WalletItem> {
  @override
  Widget build(BuildContext context) {
    S _localizations = S.of(context);
    if (widget.type == WalletType.nkn) {
      return InkWell(
        onTap: widget.onTap ??
            () {
              Navigator.of(context).pushNamed(NknWalletDetailScreen.routeName,arguments: {
                'wallet': widget.schema
              });
            },
        child: Container(
          decoration: BoxDecoration(
            color: DefaultTheme.backgroundLightColor,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Expanded(
                  flex: 0,
                  child: Hero(
                    tag: 'avatar:${widget.schema.address}',
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: DefaultTheme.logoBackground,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: SvgPicture.asset('assets/logo.svg', color: Color(0xFF253A7E)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Label(
                            widget.schema.name,
                            type: LabelType.h3,
                          ),
                          Label(
                            Format.nknFormat(widget.schema.balance, decimalDigits: 4, symbol: 'NKN'),
                            type: LabelType.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 0,
                  child: Container(
                    alignment: Alignment.centerRight,
                    height: 44,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            height: 18,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), color: Color(0x1500CC96)),
                            child: Text(_localizations.mainnet, style: TextStyle(color: Color(0xFF00CC96), fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (widget.type == WalletType.eth) {
      return InkWell(
        onTap: widget.onTap ??
            () {
              Navigator.of(context).pushNamed(NknWalletDetailScreen.routeName, arguments: {
                'wallet': widget.schema,
              });
            },
        child: Container(
          decoration: BoxDecoration(
            color: DefaultTheme.backgroundLightColor,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                flex: 0,
                child: Hero(
                  tag: 'avatar:${widget.schema.address}',
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: DefaultTheme.logoBackground,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: SvgPicture.asset('assets/logo.svg', color: DefaultTheme.nknLogoColor),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 48,
                        child: Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: DefaultTheme.ethLogoColor, shape: BoxShape.circle),
                          child: SvgPicture.asset('assets/ethereum-logo.svg'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: 44,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Label(widget.schema.name, type: LabelType.h3),
                      Label(
                        Format.nknFormat(widget.schema.balance, symbol: 'NKN'),
                        type: LabelType.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: Container(
                  alignment: Alignment.centerRight,
                  height: 44,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(9)), color: DefaultTheme.ethLogoColor.withAlpha(25)),
                          child: Text(
                            _localizations.ERC_20,
                            style: TextStyle(color: DefaultTheme.ethLogoColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Label(
                          Format.nknFormat(widget.schema.balanceEth, symbol: 'ETH'),
                          type: LabelType.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
