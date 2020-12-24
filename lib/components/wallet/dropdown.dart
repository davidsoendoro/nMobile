import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nmobile/blocs/wallet/filtered_wallets_bloc.dart';
import 'package:nmobile/blocs/wallet/filtered_wallets_event.dart';
import 'package:nmobile/blocs/wallet/filtered_wallets_state.dart';
import 'package:nmobile/components/label.dart';
import 'package:nmobile/generated/l10n.dart';
import 'package:nmobile/helpers/format.dart';
import 'package:nmobile/schemas/wallet.dart';
import 'package:nmobile/theme/theme.dart';
import 'package:nmobile/utils/assets.dart';

class WalletDropdown extends StatefulWidget {
  final WalletSchema schema;
  final String title;

  WalletDropdown({this.schema, this.title});

  @override
  _WalletDropdownState createState() => _WalletDropdownState();
}

class _WalletDropdownState extends State<WalletDropdown> {
  FilteredWalletsBloc _filteredWalletsBloc;

  @override
  void initState() {
    super.initState();
    _filteredWalletsBloc = BlocProvider.of<FilteredWalletsBloc>(context);
    var filter = widget.schema != null ? (x) => x.address == widget.schema.address : null;
    _filteredWalletsBloc.add(LoadWalletFilter(filter));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    S _localizations = S.of(context);
    return InkWell(
      onTap: () {
      },
      child: BlocBuilder<FilteredWalletsBloc, FilteredWalletsState>(
        builder: (context, state) {
          if (state is FilteredWalletsLoaded) {
            var wallet = state.filteredWallets.first;
            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: DefaultTheme.backgroundColor2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 0,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
                          child: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: DefaultTheme.lineColor,
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            child: SvgPicture.asset('assets/logo.svg', color: DefaultTheme.nknLogoColor),
                          ),
                        ),
                        wallet.type == WalletSchema.NKN_WALLET
                            ? Container()
                            : Positioned(
                                top: 8,
                                left: 32,
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
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Label(wallet.name, type: LabelType.h3),
                        ),
                        Label(
                          Format.nknFormat(wallet.balance, decimalDigits: 4, symbol: 'NKN'),
                          type: LabelType.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        wallet.type == WalletSchema.NKN_WALLET
                            ? Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 2, bottom: 2, left: 8, right: 8),
                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(9)), color: DefaultTheme.successColor.withAlpha(25)),
                                child: Text(
                                  _localizations.mainnet,
                                  style: TextStyle(color: DefaultTheme.successColor, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              )
                            : Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 2, bottom: 2, left: 8, right: 8),
                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(9)), color: DefaultTheme.ethLogoColor.withAlpha(25)),
                                child: Text(
                                  _localizations.ERC_20,
                                  style: TextStyle(color: DefaultTheme.ethLogoColor, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: (wallet.type == WalletSchema.NKN_WALLET
                              ? Container()
                              : Label(
                                  Format.nknFormat(wallet.balanceEth, symbol: 'ETH'),
                                  type: LabelType.bodySmall,
                                )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
