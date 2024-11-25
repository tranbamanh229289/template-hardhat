// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library ECDSA {
  /* Error */
  error SignatureLengthInvalid();
  error InvalidSignatureS();

  function recover(
    bytes32 hash,
    bytes32 r,
    bytes32 s,
    uint8 v
  ) internal pure returns (address signer) {
    if (
      uint256(s) >
      0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
    ) {
      revert InvalidSignatureS();
    }
    return _recover(hash, r, s, v);
  }

  function recover(
    bytes32 hash,
    bytes memory signature
  ) internal pure returns (address signer) {
    if (signature.length == 65) {
      bytes32 r;
      bytes32 s;
      uint8 v;
      assembly ("memory-safe") {
        r := mload(add(signature, 0x20))
        s := mload(add(signature, 0x40))
        v := byte(0, add(signature, 0x60))
      }
      return recover(hash, r, s, v);
    } else {
      revert SignatureLengthInvalid();
    }
  }

  function _recover(
    bytes32 hash,
    bytes32 r,
    bytes32 s,
    uint8 v
  ) internal pure returns (address) {
    return ecrecover(hash, v, r, s);
  }
}
