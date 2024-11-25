// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Hash} from "../lib/Hash.sol";

abstract contract EIP712 {
  // EIP712 Format:  keccak256("EIP721Domain(string name,string version,uint256 chainId,address verifyingContract)");
  bytes32 private constant TYPE_HASH =
    keccak256(
      "EIP721Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );
  bytes32 private immutable nameHashed;
  bytes32 private immutable versionHashed;

  constructor(string memory name, string memory version) {
    nameHashed = keccak256(bytes(name));
    versionHashed = keccak256(bytes(version));
  }

  function _buildDomainSeparator() internal view returns (bytes32) {
    return
      keccak256(
        abi.encode(
          TYPE_HASH,
          nameHashed,
          versionHashed,
          block.chainid,
          address(this)
        )
      );
  }

  function hashData(bytes32 structHash) internal view returns (bytes32) {
    return Hash.computeHashData(_buildDomainSeparator(), structHash);
  }
}
