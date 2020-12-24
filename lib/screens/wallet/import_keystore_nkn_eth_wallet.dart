import 'dart:io';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nkn_sdk_flutter/wallet.dart';
import 'package:nmobile/blocs/wallet/wallets_bloc.dart';
import 'package:nmobile/blocs/wallet/wallets_event.dart';
import 'package:nmobile/components/button/button.dart';
import 'package:nmobile/components/label.dart';
import 'package:nmobile/components/textbox.dart';
import 'package:nmobile/consts/wallet_error.dart';
import 'package:nmobile/generated/l10n.dart';
import 'package:nmobile/helpers/nkn_erc20.dart';
import 'package:nmobile/helpers/validator.dart';
import 'package:nmobile/schemas/wallet.dart';

class ImportKeystoreWallet extends StatefulWidget {
  final WalletType type;

  const ImportKeystoreWallet({this.type});

  @override
  _ImportKeystoreWalletState createState() => _ImportKeystoreWalletState();
}

class _ImportKeystoreWalletState extends State<ImportKeystoreWallet> with SingleTickerProviderStateMixin {
  GlobalKey _formKey = new GlobalKey<FormState>();
  bool _formValid = false;
  TextEditingController _keystoreController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FocusNode _keystoreFocusNode = FocusNode();
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _confirmPasswordFocusNode = FocusNode();
  WalletsBloc _walletsBloc;
  String _keystore;
  String _name;
  String _password;

  @override
  void initState() {
    super.initState();
    _walletsBloc = BlocProvider.of<WalletsBloc>(context);
  }

  @override
  void dispose() {
    EasyLoading.dismiss();
    super.dispose();
  }

  next() async {
    if ((_formKey.currentState as FormState).validate()) {
      (_formKey.currentState as FormState).save();
      EasyLoading.show(maskType: EasyLoadingMaskType.black);
      try {
        if (widget.type == WalletType.nkn) {
          Wallet wallet = await Wallet.restore(_keystore, _password);
          var keystore = wallet.keystore;
          String address = wallet.address;
          _walletsBloc.add(AddWallet(WalletSchema(address: address, type: WalletSchema.NKN_WALLET, name: _name), keystore));
        } else if (widget.type == WalletType.eth) {
          final ethWallet = Ethereum.restoreWallet(name: _name, keystore: _keystore, password: _password);
          final ethSchema = WalletSchema(address: (await ethWallet.address).hex, name: ethWallet.name, type: WalletSchema.ETH_WALLET);
          _walletsBloc.add(AddWallet(ethSchema, ethWallet.keystore));
        }
        EasyLoading.dismiss();
        BotToast.showText(text: S.of(context).success);
        Navigator.of(context).pop();
      } catch (e) {
        EasyLoading.dismiss();
        if (e.message == WalletError.WALLET_PASSWORD_WRONG) {
          BotToast.showText(text: S.of(context).password_wrong);
        } else {
          BotToast.showText(text: e.message);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    S _localizations = S.of(context);
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onChanged: () {
        setState(() {
          _formValid = (_formKey.currentState as FormState).validate();
        });
      },
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(top: 0),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32, left: 20, right: 20),
                    child: Flex(
                      direction: Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 0,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                                  child: Label(
                                    _localizations.import_with_keystore_title,
                                    type: LabelType.h2,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 32),
                                  child: Label(
                                    _localizations.import_with_keystore_desc,
                                    type: LabelType.bodyRegular,
                                    textAlign: TextAlign.start,
                                    softWrap: true,
                                  ),
                                ),
                                Label(
                                  _localizations.keystore,
                                  type: LabelType.h4,
                                  textAlign: TextAlign.start,
                                ),
                                Textbox(
                                  multi: true,
                                  controller: _keystoreController,
                                  hintText: _localizations.input_keystore,
                                  focusNode: _keystoreFocusNode,
                                  onSaved: (v) => _keystore = v,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                                  },
                                  suffixIcon: GestureDetector(
                                    onTap: () async {
                                      FilePickerResult result = await FilePicker.platform.pickFiles();
                                      if (result != null) {
                                        File file = File(result.files.single.path);
                                        _keystoreController.text = file.readAsStringSync();
                                      }
                                    },
                                    child: Container(
                                      width: 20,
                                      alignment: Alignment.bottomCenter,
                                      child: Icon(
                                        FontAwesomeIcons.paperclip,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  validator: widget.type == WalletType.nkn ? Validator.of(context).keystore() : Validator.of(context).keystoreEth(),
                                ),
                                Label(
                                  _localizations.wallet_name,
                                  type: LabelType.h4,
                                  textAlign: TextAlign.start,
                                ),
                                Textbox(
                                  focusNode: _nameFocusNode,
                                  hintText: _localizations.hint_enter_wallet_name,
                                  onSaved: (v) => _name = v,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                                  },
                                  textInputAction: TextInputAction.next,
                                  validator: Validator.of(context).walletName(),
                                ),
                                Label(
                                  _localizations.wallet_password,
                                  type: LabelType.h4,
                                  textAlign: TextAlign.start,
                                ),
                                Textbox(
                                  focusNode: _passwordFocusNode,
                                  controller: _passwordController,
                                  hintText: _localizations.input_password,
                                  onSaved: (v) => _password = v,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                                  },
                                  validator: Validator.of(context).password(),
                                  password: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: 8, top: 8),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: Button(
                        text: widget.type == WalletType.nkn ? _localizations.import_nkn_wallet : _localizations.import_ethereum_wallet,
                        disabled: !_formValid,
                        onPressed: next,
                      ),
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
