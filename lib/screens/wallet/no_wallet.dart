import 'package:flutter/material.dart';
import 'package:nmobile/components/button/button.dart';
import 'package:nmobile/components/label.dart';
import 'package:nmobile/generated/l10n.dart';
import 'package:nmobile/schemas/wallet.dart';
import 'package:nmobile/theme/theme.dart';

import 'create_nkn_wallet.dart';
import 'import_nkn_eth_wallet.dart';

class NoWalletScreen extends StatefulWidget {
  static const String routeName = '/no_wallet';

  @override
  _NoWalletScreenState createState() => _NoWalletScreenState();
}

class _NoWalletScreenState extends State<NoWalletScreen> {
  @override
  Widget build(BuildContext context) {
    S _localizations = S.of(context);

    final screenSize = MediaQuery.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints.expand(),
      child: Container(
        color: DefaultTheme.backgroundColor4,
        constraints: BoxConstraints.expand(),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Container(
              height: screenSize.size.height - screenSize.padding.top - screenSize.padding.bottom,
              child: Padding(
                padding: const EdgeInsets.only(top: 60, bottom: 60),
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(),
                        child: Image(image: AssetImage('assets/wallet/pig.png'), width: 120),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Label(
                            _localizations.no_wallet_title,
                            type: LabelType.h2,
                            dark: true,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16, left: 24, right: 24),
                            child: Label(
                              _localizations.no_wallet_desc,
                              type: LabelType.h4,
                              dark: true,
                              softWrap: true,
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          children: <Widget>[
                            Button(
                              text: _localizations.no_wallet_create,
                              onPressed: () {
                                Navigator.pushNamed(context, CreateNknWalletScreen.routeName);
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Button(
                                text: _localizations.no_wallet_import,
                                backgroundColor: Color(0xFF232D50),
                                onPressed: () {
                                  Navigator.pushNamed(context, ImportWalletScreen.routeName, arguments: {'type': WalletType.nkn});
                                },
                              ),
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
    );
  }
}
