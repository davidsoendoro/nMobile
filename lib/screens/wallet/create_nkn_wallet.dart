import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_it/get_it.dart';
import 'package:nkn_sdk_flutter/wallet.dart';
import 'package:nmobile/blocs/wallet/wallets_bloc.dart';
import 'package:nmobile/blocs/wallet/wallets_event.dart';
import 'package:nmobile/components/button/button.dart';
import 'package:nmobile/components/label.dart';
import 'package:nmobile/components/layout/header.dart';
import 'package:nmobile/components/textbox.dart';
import 'package:nmobile/generated/l10n.dart';
import 'package:nmobile/helpers/validator.dart';
import 'package:nmobile/schemas/wallet.dart';
import 'package:nmobile/theme/theme.dart';
import 'package:nmobile/utils/assets.dart';

class CreateNknWalletScreen extends StatefulWidget {
  static const String routeName = '/wallet/create_nkn_wallet';

  @override
  _CreateNknWalletScreenState createState() => _CreateNknWalletScreenState();
}

class _CreateNknWalletScreenState extends State<CreateNknWalletScreen> {
  final GetIt locator = GetIt.instance;
  GlobalKey _formKey = new GlobalKey<FormState>();
  bool _formValid = false;
  TextEditingController _passwordController = TextEditingController();
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _confirmPasswordFocusNode = FocusNode();

  WalletsBloc _walletsBloc;
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
      Wallet wallet = await Wallet.create(null, _password);
      _walletsBloc.add(AddWallet(WalletSchema(address: wallet.address, type: WalletSchema.NKN_WALLET, name: _name), wallet.keystore));
      EasyLoading.dismiss();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    S _localizations = S.of(context);
    return Scaffold(
      appBar: Header(
        title: _localizations.create_nkn_wallet_title,
        backgroundColor: DefaultTheme.backgroundColor4,
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height),
                  color: DefaultTheme.backgroundColor4,
                  child: Flex(direction: Axis.vertical, children: <Widget>[
                    Expanded(
                      flex: 0,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 32),
                            child: assetImage('wallet/create-wallet.png', width: 142),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: 400),
                child: Container(
                  constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height - 280),
                  color: DefaultTheme.backgroundColor4,
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: DefaultTheme.backgroundLightColor,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                          ),
                          child: Form(
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
                                    padding: EdgeInsets.only(top: 4),
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
                                                      Label(
                                                        _localizations.wallet_name,
                                                        type: LabelType.h3,
                                                        textAlign: TextAlign.start,
                                                      ),
                                                      Textbox(
                                                        hintText: _localizations.hint_enter_wallet_name,
                                                        focusNode: _nameFocusNode,
                                                        onSaved: (v) => _name = v,
                                                        onFieldSubmitted: (_) {
                                                          FocusScope.of(context).requestFocus(_passwordFocusNode);
                                                        },
                                                        textInputAction: TextInputAction.next,
                                                        validator: Validator.of(context).walletName(),
                                                      ),
                                                      SizedBox(height: 14),
                                                      Label(
                                                        _localizations.wallet_password,
                                                        type: LabelType.h3,
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
                                                        textInputAction: TextInputAction.next,
                                                        validator: Validator.of(context).password(),
                                                        password: true,
                                                      ),
                                                      Text(
                                                        _localizations.wallet_password_mach,
                                                        style: TextStyle(color: DefaultTheme.fontColor2, fontSize: DefaultTheme.bodySmallFontSize),
                                                      ),
                                                      SizedBox(height: 24),
                                                      Label(
                                                        _localizations.confirm_password,
                                                        type: LabelType.h3,
                                                        textAlign: TextAlign.start,
                                                      ),
                                                      Textbox(
                                                        focusNode: _confirmPasswordFocusNode,
                                                        hintText: _localizations.input_password_again,
                                                        validator: Validator.of(context).confrimPassword(_passwordController.text),
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
                                            padding: EdgeInsets.only(left: 20, right: 20),
                                            child: Button(
                                              text: _localizations.create_wallet,
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
                          ),
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
    );
  }
}
