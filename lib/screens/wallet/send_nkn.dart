import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:nkn_sdk_flutter/wallet.dart';
import 'package:nmobile/blocs/wallet/filtered_wallets_bloc.dart';
import 'package:nmobile/blocs/wallet/filtered_wallets_state.dart';
import 'package:nmobile/blocs/wallet/wallets_bloc.dart';
import 'package:nmobile/blocs/wallet/wallets_state.dart';
import 'package:nmobile/components/button/button.dart';
import 'package:nmobile/components/dialog/modal.dart';
import 'package:nmobile/components/label.dart';
import 'package:nmobile/components/layout/expansion_layout.dart';
import 'package:nmobile/components/layout/header.dart';
import 'package:nmobile/components/textbox.dart';
import 'package:nmobile/components/wallet/dropdown.dart';
import 'package:nmobile/consts/wallet_error.dart';
import 'package:nmobile/generated/l10n.dart';
import 'package:nmobile/helpers/format.dart';
import 'package:nmobile/helpers/validator.dart';
import 'package:nmobile/schemas/wallet.dart';
import 'package:nmobile/screens/scanner.dart';
import 'package:nmobile/services/task_service.dart';
import 'package:nmobile/storages/wallet.dart';
import 'package:nmobile/theme/theme.dart';
import 'package:nmobile/utils/assets.dart';
import 'package:nmobile/utils/wallet.dart';

class SendNknScreen extends StatefulWidget {
  static const String routeName = '/wallet/send_nkn';
  final arguments;
  WalletSchema wallet;

  SendNknScreen({this.arguments}) {
    wallet = arguments['wallet'];
  }

  @override
  _SendNknScreenState createState() => _SendNknScreenState();
}

class _SendNknScreenState extends State<SendNknScreen> {
  S _localizations;
  final GetIt locator = GetIt.instance;
  WalletStorage _walletStorage = WalletStorage();
  GlobalKey _formKey = new GlobalKey<FormState>();
  bool _formValid = false;
  TextEditingController _amountController = TextEditingController();
  TextEditingController _sendToController = TextEditingController();
  TextEditingController _feeController = TextEditingController();
  FocusNode _amountFocusNode = FocusNode();
  FocusNode _sendToFocusNode = FocusNode();
  FocusNode _feeToFocusNode = FocusNode();

  WalletSchema wallet;
  bool _showFeeLayout = false;
  var _amount;
  var _sendTo;
  double _fee = 0.1;
  double _sliderFee = 0.1;
  double _sliderFeeMin = 0;
  double _sliderFeeMax = 10;

  @override
  void initState() {
    super.initState();
    locator<TaskService>().queryNknWalletBalanceTask();
    _feeController.text = _fee.toString();
  }

  next() async {
    if ((_formKey.currentState as FormState).validate()) {
      (_formKey.currentState as FormState).save();

      String password = await _walletStorage.authPassword(widget.wallet.address);
      if (password != null) {
        String keystore = await _walletStorage.getKeystore(widget.wallet.address);
        final result = transferAction(keystore, password);
        Navigator.pop(context, result);
      }
    }
  }

  Future<bool> transferAction(String keystore, String password) async {
    try {
      Wallet wallet = await Wallet.restore(keystore, password);
      String txHash = await wallet.transfer(_sendTo, _amount, fee: _fee.toString());
      if(txHash != null) {
        locator<TaskService>().queryNknWalletBalanceTask();
      }
      return txHash?.isNotEmpty == true;
    } catch (e) {
      if (e.message == WalletError.WALLET_PASSWORD_WRONG) {
        BotToast.showText(text: _localizations.password_wrong);
      } else if (e.message == 'INTERNAL ERROR, can not append tx to txpool: not sufficient funds') {
        BotToast.showText(text: e.message);
      } else {
        BotToast.showText(text: _localizations.failure);
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _localizations = S.of(context);
    return Scaffold(
      appBar: Header(
        title: _localizations.send_nkn,
        backgroundColor: DefaultTheme.backgroundColor4,
        actions: [
          IconButton(
            icon: assetIcon(
              'scan',
              width: 24,
              color: DefaultTheme.backgroundLightColor,
            ),
            onPressed: () async {
              var qrData = await Navigator.of(context).pushNamed(ScannerScreen.routeName);
              var jsonFormat;
              var jsonData;
              try {
                jsonData = jsonDecode(qrData);
                jsonFormat = true;
              } on Exception catch (e) {
                jsonFormat = false;
              }
              if (jsonFormat) {
                _sendToController.text = jsonData['address'];
                _amountController.text = jsonData['amount'].toString();
              } else if (verifyAddress(qrData)) {
                _sendToController.text = qrData;
              } else {
                await ModalDialog.of(context).show(
                  height: 240,
                  content: Label(
                    _localizations.error_unknown_nkn_qrcode,
                    type: LabelType.bodyRegular,
                  ),
                );
              }
            },
          )
        ],
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
                            padding: EdgeInsets.only(bottom: 32, left: 20, right: 20),
                            child: Image(
                              image: AssetImage("assets/wallet/transfer-header.png"),
                            ),
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
                  constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height - 200),
                  color: DefaultTheme.backgroundColor4,
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: BlocBuilder<FilteredWalletsBloc, FilteredWalletsState>(
                          builder: (context, state) {
                            if (state is FilteredWalletsLoaded) {
                              wallet = state.filteredWallets.first;
                              return Container(
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
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Scrollbar(
                                          child: SingleChildScrollView(
                                            child: Padding(
                                              padding: EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 32),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  WalletDropdown(
                                                    title: _localizations.select_asset_to_receive,
                                                    schema: widget.wallet ?? wallet,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 20),
                                                    child: Label(
                                                      _localizations.amount,
                                                      type: LabelType.h4,
                                                      textAlign: TextAlign.start,
                                                    ),
                                                  ),
                                                  Textbox(
                                                    padding: const EdgeInsets.only(bottom: 4),
                                                    controller: _amountController,
                                                    focusNode: _amountFocusNode,
                                                    onSaved: (v) => _amount = v,
                                                    onFieldSubmitted: (_) {
                                                      FocusScope.of(context).requestFocus(_sendToFocusNode);
                                                    },
                                                    validator: Validator.of(context).amount(),
                                                    showErrorMessage: false,
                                                    hintText: _localizations.enter_amount,
                                                    suffixIcon: GestureDetector(
                                                      onTap: () {},
                                                      child: Container(
                                                        width: 20,
                                                        alignment: Alignment.centerRight,
                                                        child: Label(_localizations.nkn, type: LabelType.label),
                                                      ),
                                                    ),
                                                    textInputAction: TextInputAction.next,
                                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                    inputFormatters: [FilteringTextInputFormatter(RegExp(r'^[0-9]+\.?[0-9]{0,8}'), allow: true)],
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 20),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Row(
                                                          children: <Widget>[
                                                            Label(_localizations.available + ': '),
                                                            BlocBuilder<WalletsBloc, WalletsState>(
                                                              builder: (context, state) {
                                                                if (state is WalletsLoaded) {
                                                                  var w = state.wallets.firstWhere((x) => x == wallet, orElse: () => null);
                                                                  if (w != null) {
                                                                    return Label(
                                                                      Format.nknFormat(w.balance, decimalDigits: 8, symbol: 'NKN'),
                                                                      color: DefaultTheme.fontColor1,
                                                                    );
                                                                  }
                                                                }
                                                                return Label('-- NKN', color: DefaultTheme.fontColor1);
                                                              },
                                                            )
                                                          ],
                                                        ),
                                                        InkWell(
                                                          child: Label(
                                                            _localizations.max,
                                                            color: DefaultTheme.primaryColor,
                                                            type: LabelType.bodyRegular,
                                                          ),
                                                          onTap: () {
                                                            _amountController.text = wallet.balance.toString();
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Label(
                                                    _localizations.send_to,
                                                    type: LabelType.h4,
                                                    textAlign: TextAlign.start,
                                                  ),
                                                  Textbox(
                                                    focusNode: _sendToFocusNode,
                                                    controller: _sendToController,
                                                    onSaved: (v) => _sendTo = v,
                                                    onFieldSubmitted: (_) {
                                                      FocusScope.of(context).requestFocus(_feeToFocusNode);
                                                    },
                                                    validator: Validator.of(context).nknAddress(),
                                                    textInputAction: TextInputAction.next,
                                                    hintText: _localizations.enter_receive_address,
                                                    suffixIcon: GestureDetector(
                                                      onTap: () async {
                                                        // if (account?.client != null) {
                                                        //   var contact = await Navigator.of(context).pushNamed(ContactHome.routeName, arguments: true);
                                                        //   if (contact is ContactSchema) {
                                                        //     _sendToController.text = contact.nknWalletAddress;
                                                        //   }
                                                        // } else {
                                                        //   showToast('D-Chat not login');
                                                        // }
                                                      },
                                                      child: Container(
                                                        width: 20,
                                                        alignment: Alignment.centerRight,
                                                        child: Icon(FontAwesomeIcons.solidAddressBook),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 20),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: <Widget>[
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              _showFeeLayout = !_showFeeLayout;
                                                            });
                                                          },
                                                          child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: <Widget>[
                                                              Label(
                                                                _localizations.fee,
                                                                color: DefaultTheme.primaryColor,
                                                                type: LabelType.h4,
                                                                textAlign: TextAlign.start,
                                                              ),
                                                              RotatedBox(
                                                                quarterTurns: _showFeeLayout ? 2 : 0,
                                                                child: assetIcon('down', color: DefaultTheme.primaryColor, width: 20),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 120,
                                                          child: Textbox(
                                                            controller: _feeController,
                                                            focusNode: _feeToFocusNode,
                                                            padding: const EdgeInsets.only(bottom: 0),
                                                            onSaved: (v) => _fee = double.parse(v ?? 0),
                                                            onChanged: (v) {
                                                              setState(() {
                                                                double fee = v.isNotEmpty ? double.parse(v) : 0;
                                                                if (fee > _sliderFeeMax) {
                                                                  fee = _sliderFeeMax;
                                                                } else if (fee < _sliderFeeMin) {
                                                                  fee = _sliderFeeMin;
                                                                }
                                                                _sliderFee = fee;
                                                              });
                                                            },
                                                            suffixIcon: GestureDetector(
                                                              onTap: () {},
                                                              child: Container(
                                                                width: 20,
                                                                alignment: Alignment.centerRight,
                                                                child: Label(_localizations.nkn, type: LabelType.label),
                                                              ),
                                                            ),
                                                            keyboardType: TextInputType.numberWithOptions(
                                                              decimal: true,
                                                            ),
                                                            textInputAction: TextInputAction.done,
                                                            inputFormatters: [FilteringTextInputFormatter(RegExp(r'^[0-9]+\.?[0-9]{0,8}'), allow: true)],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  ExpansionLayout(
                                                    isExpanded: _showFeeLayout,
                                                    child: Container(
                                                        width: double.infinity,
                                                        padding: const EdgeInsets.only(top: 0),
                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: <Widget>[
                                                                Label(
                                                                  _localizations.slow,
                                                                  type: LabelType.bodySmall,
                                                                  color: DefaultTheme.primaryColor,
                                                                ),
                                                                Label(
                                                                  _localizations.average,
                                                                  type: LabelType.bodySmall,
                                                                  color: DefaultTheme.primaryColor,
                                                                ),
                                                                Label(
                                                                  _localizations.fast,
                                                                  type: LabelType.bodySmall,
                                                                  color: DefaultTheme.primaryColor,
                                                                ),
                                                              ],
                                                            ),
                                                            Slider(
                                                              value: _sliderFee,
                                                              onChanged: (v) {
                                                                setState(() {
                                                                  _sliderFee = _fee = v;
                                                                  _feeController.text = _fee.toStringAsFixed(2);
                                                                });
                                                              },
                                                              max: _sliderFeeMax,
                                                              min: _sliderFeeMin,
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                ],
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
                                                    text: _localizations.continue_text,
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
                              );
                            }
                            return Container();
                          },
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
