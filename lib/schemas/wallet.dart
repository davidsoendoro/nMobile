import 'package:equatable/equatable.dart';

enum WalletType { nkn, eth }

class WalletSchema extends Equatable {
  static const String NKN_WALLET = 'nkn';
  static const String ETH_WALLET = 'eth';
  String address;
  String type;
  String name;
  double balance;
  String keystore;
  double balanceEth;
  bool isBackedUp;

  WalletSchema({
    this.address,
    this.type,
    this.name,
    this.balance = 0,
    this.balanceEth = 0,
    this.isBackedUp = false,
  });

  WalletSchema.fromMap(Map<String, dynamic> map) {
    this.address = map['address'];
    this.type = map['type'];
    this.name = map['name'] ?? '';
    this.balance = map['balance'] ?? 0;
    this.balanceEth = map['balanceEth'] ?? 0;
    this.isBackedUp = map['isBackedUp'] ?? false;
  }

  Map<String, dynamic> toMap() {
    return {
      'address': this.address,
      'type': this.type,
      'name': this.name,
      'balance': this.balance,
      'balanceEth': this.balanceEth,
      'isBackedUp': this.isBackedUp,
    };
  }

  @override
  List<Object> get props => [address, type, name];

  @override
  String toString() => 'WalletSchema { address: $address }';
}
