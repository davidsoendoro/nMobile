import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nmobile/blocs/wallet/wallets_bloc.dart';
import 'package:nmobile/blocs/wallet/wallets_event.dart';
import 'package:nmobile/components/button/button.dart';
import 'package:nmobile/components/dialog/bottom.dart';
import 'package:nmobile/components/label.dart';
import 'package:nmobile/components/layout/header.dart';
import 'package:nmobile/components/layout/layout.dart';
import 'package:nmobile/components/textbox.dart';
import 'package:nmobile/generated/l10n.dart';
import 'package:nmobile/theme/theme.dart';
import 'package:nmobile/utils/assets.dart';
import 'package:nmobile/utils/common.dart';

class NknWalletExportScreen extends StatefulWidget {
  static const String routeName = '/wallet/nkn_wallet_export';

  final arguments;

  NknWalletExportScreen({this.arguments}) ;

  @override
  _NknWalletExportScreenState createState() => _NknWalletExportScreenState();
}

class _NknWalletExportScreenState extends State<NknWalletExportScreen> {
  String keystore;
  String publicKey;
  String seed;
  String address;
  String name;
  WalletsBloc _walletsBloc;

  _setBackupFlag() {
    _walletsBloc.add(UpdateWalletBackedUp(address));
  }

  @override
  void initState() {
    super.initState();
    keystore = widget.arguments['keystore'];
    address = widget.arguments['address'];
    publicKey = widget.arguments['publicKey'];
    seed = widget.arguments['seed'];
    name = widget.arguments['name'];

    _walletsBloc = BlocProvider.of<WalletsBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    S _localizations = S.of(context);
    return Layout(
      headerColor: DefaultTheme.backgroundColor4,
      header: Header(
        title: _localizations.export_wallet,
        backgroundColor: DefaultTheme.backgroundColor4,
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 0, left: 20, right: 20),
        color: DefaultTheme.backgroundLightColor,
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(top: 0),
                child: SingleChildScrollView(
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      Expanded(
                        flex: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Column(
                            children: <Widget>[
                              Hero(
                                tag: 'avatar:${address}',
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                                    address.contains('NKN')
                                        ? Container()
                                        : Positioned(
                                            top: 16,
                                            left: 48,
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(color: DefaultTheme.ethLogoColor, shape: BoxShape.circle),
                                              child: SvgPicture.asset('assets/ethereum-logo.svg'),
                                            ),
                                          )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16, bottom: 40),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Label(
                                      name ?? '',
                                      type: LabelType.h2,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 0,
                                child: Column(
                                  children: <Widget>[
                                    Flex(
                                      direction: Axis.horizontal,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 0,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 0, right: 20),
                                            child: assetIcon(
                                              'wallet',
                                              color: DefaultTheme.primaryColor,
                                              width: 24,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Label(
                                                      _localizations.wallet_address,
                                                      type: LabelType.h4,
                                                      textAlign: TextAlign.start,
                                                    ),
                                                    InkWell(
                                                      child: Label(
                                                        _localizations.copy,
                                                        color: DefaultTheme.primaryColor,
                                                        type: LabelType.bodyRegular,
                                                      ),
                                                      onTap: () {
                                                        copyAction(context, address);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    copyAction(context, address);
                                                  },
                                                  child: Textbox(
                                                    value: address,
                                                    multi: true,
                                                    readOnly: true,
                                                    enabled: false,
                                                    textInputAction: TextInputAction.next,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    publicKey == null
                                        ? Container()
                                        : Flex(
                                            direction: Axis.horizontal,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 0,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 0, right: 20),
                                                  child: assetIcon(
                                                    'key',
                                                    color: DefaultTheme.primaryColor,
                                                    width: 24,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Label(
                                                            _localizations.public_key,
                                                            type: LabelType.h4,
                                                            textAlign: TextAlign.start,
                                                          ),
                                                          InkWell(
                                                            child: Label(
                                                              _localizations.copy,
                                                              color: DefaultTheme.primaryColor,
                                                              type: LabelType.bodyRegular,
                                                            ),
                                                            onTap: () {
                                                              copyAction(context, publicKey);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          copyAction(context, publicKey);
                                                        },
                                                        child: Textbox(
                                                          multi: true,
                                                          enabled: false,
                                                          value: publicKey,
                                                          readOnly: true,
                                                          textInputAction: TextInputAction.next,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                    seed == null
                                        ? Container()
                                        : Flex(
                                            direction: Axis.horizontal,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 0,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 0, right: 20),
                                                  child: assetIcon(
                                                    'key',
                                                    color: DefaultTheme.primaryColor,
                                                    width: 24,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Label(
                                                            _localizations.seed,
                                                            type: LabelType.h4,
                                                            textAlign: TextAlign.start,
                                                          ),
                                                          InkWell(
                                                            child: Label(
                                                              _localizations.copy,
                                                              color: DefaultTheme.primaryColor,
                                                              type: LabelType.bodyRegular,
                                                            ),
                                                            onTap: () {
                                                              copyAction(context, seed);
                                                              _setBackupFlag();
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          copyAction(context, seed);
                                                          _setBackupFlag();
                                                        },
                                                        child: Textbox(
                                                          multi: true,
                                                          value: seed,
                                                          readOnly: true,
                                                          enabled: false,
                                                          textInputAction: TextInputAction.next,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                    Flex(
                                      direction: Axis.horizontal,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 0,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 0, right: 20),
                                            child: assetIcon(
                                              'key',
                                              color: DefaultTheme.primaryColor,
                                              width: 24,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Label(
                                                      _localizations.keystore,
                                                      type: LabelType.h4,
                                                      textAlign: TextAlign.start,
                                                    ),
                                                    InkWell(
                                                      child: Label(
                                                        _localizations.copy,
                                                        color: DefaultTheme.primaryColor,
                                                        type: LabelType.bodyRegular,
                                                      ),
                                                      onTap: () {
                                                        copyAction(context, keystore);
                                                        _setBackupFlag();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    copyAction(context, keystore);
                                                    _setBackupFlag();
                                                  },
                                                  child: Textbox(
                                                    multi: true,
                                                    maxLines: 8,
                                                    enabled: false,
                                                    value: keystore,
                                                    readOnly: true,
                                                    textInputAction: TextInputAction.next,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            seed == null
                ? Container()
                : Expanded(
                    flex: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8, top: 8),
                        child: Column(
                          children: <Widget>[
                            Button(
                              child: Label(
                                _localizations.view_qrcode,
                                type: LabelType.h3,
                                color: DefaultTheme.primaryColor,
                              ),
                              backgroundColor: DefaultTheme.primaryColor.withAlpha(20),
                              fontColor: DefaultTheme.primaryColor,
                              onPressed: () {
                                BottomDialog.of(context).showQrcodeDialog(
                                  title: _localizations.seed + _localizations.qrcode,
                                  data: seed,
                                );
                                _setBackupFlag();
                              },
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
