import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nkn_sdk_flutter/wallet.dart';
import 'package:nmobile/blocs/wallet/wallets_bloc.dart';
import 'package:nmobile/blocs/wallet/wallets_event.dart';
import 'package:nmobile/components/button/button.dart';
import 'package:nmobile/components/label.dart';
import 'package:nmobile/components/textbox.dart';
import 'package:nmobile/generated/l10n.dart';
import 'package:nmobile/helpers/nkn_erc20.dart';
import 'package:nmobile/helpers/validator.dart';
import 'package:nmobile/schemas/wallet.dart';
import 'package:nmobile/theme/theme.dart';
import 'package:nmobile/utils/assets.dart';
import 'package:nmobile/utils/logger.dart';

import '../scanner.dart';

class ImportSeedWallet extends StatefulWidget {
  final WalletType type;

  const ImportSeedWallet({this.type});

  @override
  _ImportSeedWalletState createState() => _ImportSeedWalletState();
}

class _ImportSeedWalletState extends State<ImportSeedWallet> with SingleTickerProviderStateMixin {
  GlobalKey _formKey = new GlobalKey<FormState>();
  bool _formValid = false;
  TextEditingController _seedController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FocusNode _seedFocusNode = FocusNode();
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _confirmPasswordFocusNode = FocusNode();
  WalletsBloc _walletsBloc;
  var _seed;
  var _name;
  var _password;

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
          Wallet wallet = await Wallet.create(_seed, _password);
          _walletsBloc.add(AddWallet(WalletSchema(address: wallet.address, type: WalletSchema.NKN_WALLET, name: _name), wallet.keystore));
        } else if (widget.type == WalletType.eth) {
          final ethWallet = Ethereum.restoreWalletFromPrivateKey(name: _name, privateKey: _seed, password: _password);
          final ethSchema = WalletSchema(address: (await ethWallet.address).hex, name: ethWallet.name, type: WalletSchema.ETH_WALLET);
          _walletsBloc.add(AddWallet(ethSchema, ethWallet.keystore));
        }
        EasyLoading.dismiss();
        BotToast.showText(text: S.of(context).success);
        Navigator.of(context).pop();
      } catch (e) {
        EasyLoading.dismiss();
        BotToast.showText(text: e.message);
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
                                    _localizations.import_with_seed_title,
                                    type: LabelType.h2,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 32),
                                  child: Label(
                                    _localizations.import_with_seed_desc,
                                    type: LabelType.bodyRegular,
                                    textAlign: TextAlign.start,
                                    softWrap: true,
                                  ),
                                ),
                                Label(
                                  _localizations.seed,
                                  type: LabelType.h4,
                                  textAlign: TextAlign.start,
                                ),
                                Textbox(
                                  controller: _seedController,
                                  focusNode: _seedFocusNode,
                                  hintText: _localizations.input_seed,
                                  onSaved: (v) => _seed = v,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_nameFocusNode);
                                  },
                                  suffixIcon: GestureDetector(
                                    onTap: () async {
                                      var qrData = await Navigator.of(context).pushNamed(ScannerScreen.routeName);
                                      logger.d(qrData);
                                      _seed = _seedController.text = qrData;
                                    },
                                    child: Container(
                                      width: 20,
                                      alignment: Alignment.center,
                                      child: assetIcon(
                                        'scan',
                                        width: 20,
                                        color: _seedFocusNode.hasFocus ? DefaultTheme.primaryColor: DefaultTheme.fontColor2 ,
                                      ),
                                    ),
                                  ),
                                  validator: Validator.of(context).seed(),
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
