// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ECDSA} from "./ECDSA.sol";
import {IERC1271} from "../interfaces/IERC1271.sol";

library SignatureChecker {
  function isValidSignature(
    address signer,
    bytes32 hash,
    bytes memory signature
  ) internal view returns (bool) {
    if (signer.code.length == 0) {
      address recovered = ECDSA.recover(hash, signature);
      return recovered == signer;
    } else {
      return isValidERC1271Signature(signer, hash, signature);
    }
  }

  function isValidERC1271Signature(
    address signer,
    bytes32 hash,
    bytes memory signature
  ) internal view returns (bool) {
    (bool success, bytes memory result) = signer.staticcall(
      abi.encodeCall(IERC1271.isValidSignature, (hash, signature))
    );
    return
      success &&
      result.length >= 32 &&
      abi.decode(result, (bytes32)) ==
      bytes32(IERC1271.isValidSignature.selector);
  }
}
