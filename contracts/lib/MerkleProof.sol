// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Hash} from "./Hash.sol";

library MerkleProof {
  function verify(
    bytes32[] memory merkleProof,
    bytes32 root,
    bytes32 leaf
  ) internal pure returns (bool) {
    return _verify(merkleProof, leaf) == root;
  }

  function _verify(
    bytes32[] memory merkleProof,
    bytes32 leaf
  ) internal pure returns (bytes32 computeHash) {
    computeHash = leaf;
    for (uint256 i = 0; i < merkleProof.length; i++) {
      computeHash = Hash.computeKeccak256(computeHash, merkleProof[i]);
    }
  }
}
