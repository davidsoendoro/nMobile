import 'dart:typed_data';
import 'dart:ui';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nmobile/blocs/wallet/filtered_wallets_bloc.dart';
import 'package:nmobile/blocs/wallet/filtered_wallets_state.dart';
import 'package:nmobile/components/button/button.dart';
import 'package:nmobile/components/label.dart';
import 'package:nmobile/components/layout/header.dart';
import 'package:nmobile/components/layout/layout.dart';
import 'package:nmobile/generated/l10n.dart';
import 'package:nmobile/schemas/wallet.dart';
import 'package:nmobile/theme/theme.dart';
import 'package:nmobile/utils/assets.dart';
import 'package:nmobile/utils/common.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveNknScreen extends StatefulWidget {
  static const String routeName = '/wallet/recieve_nkn';
  final arguments;
  WalletSchema wallet;

  ReceiveNknScreen({this.arguments}) {
    wallet = arguments['wallet'];
  }

  @override
  _ReceiveNknScreenState createState() => _ReceiveNknScreenState();
}

class _ReceiveNknScreenState extends State<ReceiveNknScreen> {
  final GetIt locator = GetIt.instance;
  GlobalKey globalKey = new GlobalKey();
  WalletSchema wallet;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    S _localizations = S.of(context);
    return Layout(
      headerColor: DefaultTheme.backgroundColor4,
      header: Header(
        title: _localizations.receive_nkn,
        backgroundColor: DefaultTheme.backgroundColor4,
        actions: [
          IconButton(
            icon: assetIcon(
              'share',
              width: 24,
              color: DefaultTheme.backgroundLightColor,
            ),
            onPressed: () async {
              RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
              var image = await boundary.toImage();
              ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
              Uint8List pngBytes = byteData.buffer.asUint8List();
              await Share.file(_localizations.receive_nkn, 'qrcode.png', pngBytes, 'image/png', text: wallet.address);
            },
          )
        ],
      ),
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: BlocBuilder<FilteredWalletsBloc, FilteredWalletsState>(
                builder: (context, state) {
                  if (state is FilteredWalletsLoaded) {
                    wallet = state.filteredWallets.first;
                    return Flex(
                      direction: Axis.vertical,
                      children: <Widget>[
                        Expanded(
                          flex: 0,
                          child: RepaintBoundary(
                            key: globalKey,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                      color: DefaultTheme.backgroundColor2,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                      child: Column(
                                        children: <Widget>[
                                          Label(
                                            _localizations.wallet_address,
                                            type: LabelType.h4,
                                            textAlign: TextAlign.start,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                                            child: Label(
                                              wallet.address,
                                              type: LabelType.bodyRegular,
                                              textAlign: TextAlign.start,
                                              softWrap: true,
                                            ),
                                          ),
                                          InkWell(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 8.0),
                                                  child: assetIcon(
                                                    'copy',
                                                    width: 24,
                                                    color: DefaultTheme.primaryColor,
                                                  ),
                                                ),
                                                Label(
                                                  _localizations.copy_to_clipboard,
                                                  color: DefaultTheme.primaryColor,
                                                  type: LabelType.h4,
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              copyAction(context, wallet.address);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(top: 24),
                                  alignment: Alignment.center,
                                  child: QrImage(
                                    data: wallet.address,
                                    backgroundColor: DefaultTheme.backgroundLightColor,
                                    version: QrVersions.auto,
                                    size: 240.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: 8, top: 8, left: 20, right: 20),
                child: Column(
                  children: <Widget>[
                    Button(
                      child: Label(_localizations.done, type: LabelType.h3),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
