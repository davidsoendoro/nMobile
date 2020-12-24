import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nmobile/generated/l10n.dart';
import 'package:nmobile/schemas/wallet.dart';
import 'package:nmobile/theme/theme.dart';

import 'bottom.dart';

class SelectWalletTypeDialog extends StatefulWidget {
  @override
  _SelectWalletTypeDialogState createState() => _SelectWalletTypeDialogState();
  final BuildContext _context;

  SelectWalletTypeDialog.of(this._context);

  Future<WalletType> show() {
    return BottomDialog.of(_context).showBottomDialog<WalletType>(
      height: 330,
      title: S.of(_context).select_wallet_type,
      child: this,
    );
  }

  close({WalletType type}) {
    Navigator.of(_context).pop(type);
  }
}

class _SelectWalletTypeDialogState extends State<SelectWalletTypeDialog> {
  S _localizations;

  @override
  Widget build(BuildContext context) {
    _localizations = S.of(context);
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: Text(
              _localizations.select_wallet_type_desc,
              style: TextStyle(fontSize: DefaultTheme.h4FontSize, color: DefaultTheme.fontColor2),
            ),
          ),
          _getItemNkn(context),
          _getItemEth(context),
        ],
      ),
    );
  }

  Widget _getItemNkn(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.close(type: WalletType.nkn);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        height: 72,
        child: Flex(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 12, right: 10),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: DefaultTheme.logoBackground,
                  ),
                  child: SvgPicture.asset('assets/logo.svg', color: DefaultTheme.nknLogoColor),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: DefaultTheme.backgroundColor2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _localizations.nkn_mainnet,
                      style: TextStyle(fontSize: DefaultTheme.h3FontSize, color: DefaultTheme.fontColor1, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(9)), color: DefaultTheme.successColor.withAlpha(25)),
                      child: Text(
                        _localizations.mainnet,
                        style: TextStyle(color: DefaultTheme.successColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getItemEth(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.close(type: WalletType.eth);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        height: 72,
        child: Flex(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 12, right: 10),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: DefaultTheme.logoBackground,
                  ),
                  child: SvgPicture.asset('assets/icon_eth_15_24.svg', color: DefaultTheme.ethLogoColor),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: DefaultTheme.backgroundColor2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _localizations.ethereum,
                      style: TextStyle(fontSize: DefaultTheme.h3FontSize, color: DefaultTheme.fontColor1, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(9)), color: DefaultTheme.successColor.withAlpha(25)),
                      child: Text(
                        _localizations.ERC_20,
                        style: TextStyle(color: DefaultTheme.ethLogoColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
