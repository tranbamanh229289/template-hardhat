// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library Hash {
  // EIP191 format: keccak256(abi.encodePacked("\x19\x01",domainSeparator,structHash));
  function computeHashData(
    bytes32 domainSeparator,
    bytes32 structHash
  ) internal pure returns (bytes32 digest) {
    assembly ("memory-safe") {
      let ptr := mload(0x40)
      mstore(ptr, hex"19_01")
      mstore(add(ptr, 0x02), domainSeparator)
      mstore(add(ptr, 0x22), structHash)
      digest := keccak256(ptr, 0x42)
    }
  }

  // keccak256(abi.encode(a,b))
  function computeKeccak256(
    bytes32 a,
    bytes32 b
  ) internal pure returns (bytes32 digest) {
    assembly ("memory-safe") {
      let ptr := mload(0x40)
      mstore(ptr, a)
      mstore(add(ptr, 0x20), b)
      digest := keccak256(ptr, 0x40)
    }
  }
}
