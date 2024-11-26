// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract MultiCall {
  struct Call {
    address target;
    bytes data;
  }
  function call(
    Call[] calldata calls
  ) external returns (bytes[] memory results) {
    for (uint256 i = 0; i < calls.length; ) {
      (bool success, bytes memory res) = calls[i].target.call(calls[i].data);
      require(success);
      results[i] = res;
      unchecked {
        i++;
      }
    }
  }
}
