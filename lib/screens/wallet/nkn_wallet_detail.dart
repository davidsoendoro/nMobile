import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nkn_sdk_flutter/wallet.dart';
import 'package:nmobile/blocs/wallet/wallets_bloc.dart';
import 'package:nmobile/blocs/wallet/wallets_event.dart';
import 'package:nmobile/blocs/wallet/wallets_state.dart';
import 'package:nmobile/components/button/button.dart';
import 'package:nmobile/components/dialog/bottom.dart';
import 'package:nmobile/components/dialog/modal.dart';
import 'package:nmobile/components/dialog/notification.dart';
import 'package:nmobile/components/label.dart';
import 'package:nmobile/components/layout/header.dart';
import 'package:nmobile/components/layout/layout.dart';
import 'package:nmobile/components/textbox.dart';
import 'package:nmobile/components/wallet/item.dart';
import 'package:nmobile/consts/wallet_error.dart';
import 'package:nmobile/generated/l10n.dart';
import 'package:nmobile/helpers/format.dart';
import 'package:nmobile/helpers/nkn_erc20.dart';
import 'package:nmobile/schemas/wallet.dart';
import 'package:nmobile/screens/wallet/send_erc_20.dart';
import 'package:nmobile/screens/wallet/send_nkn.dart';
import 'package:nmobile/storages/wallet.dart';
import 'package:nmobile/theme/theme.dart';
import 'package:nmobile/utils/assets.dart';
import 'package:nmobile/utils/common.dart';
import 'package:nmobile/utils/hash.dart';

import 'nkn_wallet_export.dart';
import 'recieve_nkn.dart';

class NknWalletDetailScreen extends StatefulWidget {
  static const String routeName = '/wallet/nkn_wallet_detail';
  final arguments;
  WalletSchema wallet;

  NknWalletDetailScreen({this.arguments}) {
    wallet = arguments['wallet'];
  }

  @override
  _NknWalletDetailScreenState createState() => _NknWalletDetailScreenState();
}

class _NknWalletDetailScreenState extends State<NknWalletDetailScreen> {
  S _localizations;
  WalletStorage _walletStorage = WalletStorage();
  WalletsBloc _walletsBloc;
  bool _isDefault = false;
  TextEditingController _nameController = TextEditingController();
  WalletSchema _currWallet;

  @override
  void initState() {
    super.initState();
    _walletsBloc = BlocProvider.of<WalletsBloc>(context);
    _nameController.text = widget.wallet.name;
  }

  _receive() {
    Navigator.of(context).pushNamed(ReceiveNknScreen.routeName, arguments: {'wallet': widget.wallet});
  }

  _send() {
    Navigator.of(context).pushNamed(
      widget.wallet.type == WalletSchema.ETH_WALLET ? SendErc20Screen.routeName : SendNknScreen.routeName,
      arguments: {'wallet': widget.wallet},
    ).then((FutureOr success) async {
      if (success != null && await success) {
        NotificationDialog.of(context).show(
          title: _localizations.transfer_initiated,
          content: _localizations.transfer_initiated_desc,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _localizations = S.of(context);
    return Layout(
      headerColor: DefaultTheme.backgroundColor4,
      header: Header(title: widget.wallet.name.toUpperCase(), backgroundColor: DefaultTheme.backgroundColor4, actions: [
        PopupMenuButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          icon: assetIcon('more', width: 24),
          onSelected: _onMenuSelected,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
            PopupMenuItem<int>(
              value: 0,
              child: Label(_localizations.export_wallet, type: LabelType.display),
            ),
            PopupMenuItem<int>(
              value: 1,
              child: Label(
                _localizations.delete_wallet,
                type: LabelType.display,
                color: DefaultTheme.strongColor,
              ),
            ),
          ],
        )
      ]),
      child: SingleChildScrollView(
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Hero(
                      tag: 'avatar:${widget.wallet.address}',
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            child: Container(
                              width: 60,
                              height: 60,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: DefaultTheme.logoBackground,
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              child: SvgPicture.asset('assets/logo.svg', color: DefaultTheme.nknLogoColor),
                            ),
                          ),
                          widget.wallet.type == WalletSchema.NKN_WALLET
                              ? Positioned(
                                  top: 16,
                                  left: 60,
                                  child: Container(),
                                )
                              : Positioned(
                                  top: 16,
                                  left: 60,
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 8, left: 34),
                            child: BlocBuilder<WalletsBloc, WalletsState>(builder: (context, state) {
                              if (state is WalletsLoaded) {
                                _currWallet = state.wallets.firstWhere((x) => x.address == widget.wallet.address, orElse: () => null);
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _currWallet != null ? Label(Format.nknFormat(_currWallet.balance, decimalDigits: 4), type: LabelType.h1) : Label('--', type: LabelType.h1),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Label('NKN', type: LabelType.bodySmall, color: DefaultTheme.fontColor1),
                                      ),
                                    ],
                                  ),
                                  _currWallet != null && _currWallet.type == WalletSchema.ETH_WALLET
                                      ? Row(
                                          children: [
                                            Label(Format.nknFormat(_currWallet.balanceEth, decimalDigits: 4), type: LabelType.bodySmall),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 6, right: 2),
                                              child: Label('ETH', type: LabelType.bodySmall, color: DefaultTheme.fontColor1),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 40),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Button(
                                text: _localizations.send,
                                onPressed: _send,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Button(
                                text: _localizations.receive,
                                onPressed: _receive,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Label(
                                _localizations.wallet_name,
                                type: LabelType.h3,
                                textAlign: TextAlign.start,
                              ),
                              InkWell(
                                child: Label(
                                  _localizations.rename,
                                  color: DefaultTheme.primaryColor,
                                  type: LabelType.bodyLarge,
                                ),
                                onTap: () {
                                  showChangeNameDialog(widget.wallet.name);
                                },
                              ),
                            ],
                          ),
                          Textbox(
                            controller: _nameController,
                            readOnly: true,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Label(
                                _localizations.wallet_address,
                                type: LabelType.h3,
                                textAlign: TextAlign.start,
                              ),
                              InkWell(
                                child: Label(
                                  _localizations.copy,
                                  color: DefaultTheme.primaryColor,
                                  type: LabelType.bodyLarge,
                                ),
                                onTap: () {
                                  copyAction(context, widget.wallet.address);
                                },
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              copyAction(context, widget.wallet.address);
                            },
                            child: Textbox(
                              value: widget.wallet.address,
                              readOnly: true,
                              enabled: false,
                              textInputAction: TextInputAction.next,
                            ),
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
    );
  }

  TextEditingController _walletNameController = TextEditingController();
  GlobalKey _nameFormKey = new GlobalKey<FormState>();

  showChangeNameDialog(String defaultName) {
    _walletNameController.text = defaultName;
    BottomDialog.of(context).showBottomDialog(
      title: S.of(context).wallet_name,
      child: Form(
        autovalidateMode: AutovalidateMode.always,
        key: _nameFormKey,
        onChanged: () {},
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Textbox(
                      controller: _walletNameController,
                      hintText: S.of(context).hint_enter_wallet_name,
                      maxLength: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      action: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 34),
        child: Button(
          text: S.of(context).save,
          width: double.infinity,
          onPressed: () async {
            if (_walletNameController.text != null && _walletNameController.text.length > 0) {
              setState(() {
                widget.wallet.name = _walletNameController.text;
                _nameController.text = _walletNameController.text;
              });
              _walletsBloc.add(UpdateWallet(widget.wallet));
            }
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  _onMenuSelected(int result) async {
    switch (result) {
      case 0:
        if (widget.wallet.type == WalletSchema.ETH_WALLET) {
          var password = await _walletStorage.authPassword(widget.wallet.address);
          if (password != null) {
            try {
              var keystore = await _walletStorage.getKeystore(widget.wallet.address);
              final ethWallet = Ethereum.restoreWallet(name: widget.wallet.name, keystore: keystore, password: password);

              Navigator.of(context).pushNamed(NknWalletExportScreen.routeName, arguments: {
                'wallet': null,
                'keystore': ethWallet.keystore,
                'address': (await ethWallet.address).hex,
                'publicKey': ethWallet.pubkeyHex,
                'seed': ethWallet.privateKeyHex,
                'name': ethWallet.name,
              });
            } catch (e) {
              BotToast.showText(text: _localizations.password_wrong);
            }
          }
        } else {
          var password = await _walletStorage.authPassword(widget.wallet.address);
          if (password != null) {
            try {
              var keystore = await _walletStorage.getKeystore(widget.wallet.address);
              var wallet = await Wallet.restore(keystore, password);
              if (wallet.address == widget.wallet.address) {
                Navigator.of(context).pushNamed(NknWalletExportScreen.routeName, arguments: {
                  'wallet': wallet,
                  'keystore': wallet.keystore,
                  'address': wallet.address,
                  'publicKey': hexEncode(wallet.publicKey),
                  'seed': hexEncode(wallet.seed),
                  'name': _isDefault ? _localizations.main_wallet : widget.wallet.name,
                });
              } else {
                BotToast.showText(text: _localizations.password_wrong);
              }
            } catch (e) {
              if (e.message == WalletError.WALLET_PASSWORD_WRONG) {
                BotToast.showText(text: _localizations.password_wrong);
              }
            }
          }
        }
        break;
      case 1:
        ModalDialog.of(context).show(
          height: 450,
          title: Label(
            _localizations.delete_wallet_confirm_title,
            type: LabelType.h2,
            softWrap: true,
          ),
          content: Column(
            children: <Widget>[
              WalletItem(
                schema: widget.wallet,
                onTap: () {},
              ),
              Label(
                _localizations.delete_wallet_confirm_text,
                type: LabelType.bodyRegular,
                softWrap: true,
              ),
            ],
          ),
          actions: <Widget>[
            Button(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: assetIcon(
                      'trash',
                      color: DefaultTheme.backgroundLightColor,
                      width: 24,
                    ),
                  ),
                  Label(
                    _localizations.delete_wallet,
                    type: LabelType.h3,
                  )
                ],
              ),
              backgroundColor: DefaultTheme.strongColor,
              width: double.infinity,
              onPressed: () async {
                _walletsBloc.add(DeleteWallet(widget.wallet));
                // todo close client
                // if (Global?.currentClient?.address != null) {
                //   var s = await NknWalletPlugin.pubKeyToWalletAddr(getPublicKeyByClientAddr(Global.currentClient?.publicKey));
                //   if (s.toString() == widget.arguments.address) {
                //     LogUtil.v('delete client ');
                //     _clientBloc.add(DisConnected());
                //   } else {
                //     LogUtil.v('no delete client ');
                //   }
                // }
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
        break;
    }
  }
}
