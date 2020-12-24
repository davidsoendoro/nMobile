import 'package:bs58check/bs58check.dart';
import 'package:web3dart/web3dart.dart';

import 'hash.dart';

const ADDRESS_GEN_PREFIX = '02b825';
const ADDRESS_GEN_PREFIX_LEN = ADDRESS_GEN_PREFIX.length ~/ 2;
const UINT160_LEN = 20;
const CHECKSUM_LEN = 4;
const ADDRESS_LEN = ADDRESS_GEN_PREFIX_LEN + UINT160_LEN + CHECKSUM_LEN;

String addressStringToProgramHash(String address) {
  var addressBytes = base58.decode(address);
  var programHashBytes = addressBytes.sublist(ADDRESS_GEN_PREFIX_LEN, addressBytes.length - CHECKSUM_LEN);
  return hexEncode(programHashBytes);
}

String getAddressStringVerifyCode(String address) {
  var addressBytes = base58.decode(address);
  var verifyBytes = addressBytes.sublist(addressBytes.length - CHECKSUM_LEN);

  return hexEncode(verifyBytes);
}

List<int> genAddressVerifyBytesFromProgramHash(String programHash) {
  programHash = ADDRESS_GEN_PREFIX + programHash;
  var verifyBytes = doubleSha256Hex(programHash);
  return verifyBytes.sublist(0, CHECKSUM_LEN);
}

String genAddressVerifyCodeFromProgramHash(String programHash) {
  var verifyBytes = genAddressVerifyBytesFromProgramHash(programHash);
  return hexEncode(verifyBytes);
}

bool verifyAddress(String address) {
  try {
    List addressBytes = base58.decode(address);
    if (addressBytes.length != ADDRESS_LEN) {
      return false;
    }
    var addressPrefixBytes = addressBytes.sublist(0, ADDRESS_GEN_PREFIX_LEN);
    var addressPrefix = hexEncode(addressPrefixBytes);
    if (addressPrefix != ADDRESS_GEN_PREFIX) {
      return false;
    }
    var programHash = addressStringToProgramHash(address);
    var addressVerifyCode = getAddressStringVerifyCode(address);
    var programHashVerifyCode = genAddressVerifyCodeFromProgramHash(programHash);
    return addressVerifyCode == programHashVerifyCode;
  } catch (e) {
    return false;
  }
}

bool isValidEthAddress(String address) {
  try {
    EthereumAddress.fromHex(address);
    return true;
  }catch (e) {
    return false;
  }
}