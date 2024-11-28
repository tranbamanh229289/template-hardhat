// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library Address {
  error StaticCallFailed();
  error CallFailed();
  error DelegateCallFailed();
  error InsufficientBalance();
  error SendValueFailed();

  function staticCall(
    address target,
    bytes memory data
  ) internal view returns (bytes memory) {
    (bool success, bytes memory result) = target.staticcall(data);
    if (success) {
      return result;
    } else {
      revert StaticCallFailed();
    }
  }

  function sendValue(address recipient, uint256 value) internal {
    if (address(this).balance < value) {
      revert InsufficientBalance();
    }
    (bool success, ) = recipient.call{value: value}("");
    if (!success) {
      revert SendValueFailed();
    }
  }

  function call(
    address target,
    bytes memory data
  ) internal returns (bytes memory) {
    (bool success, bytes memory result) = target.call(data);
    if (success) {
      return result;
    } else {
      revert CallFailed();
    }
  }

  function delegateCall(
    address target,
    bytes memory data
  ) internal returns (bytes memory) {
    (bool success, bytes memory result) = target.delegatecall(data);
    if (success) {
      return result;
    } else {
      revert DelegateCallFailed();
    }
  }
}
