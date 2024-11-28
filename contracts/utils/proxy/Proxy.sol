// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

abstract contract Proxy {
  error TransactionFailed();

  address public implementation;

  constructor(address _implementation) {
    implementation = _implementation;
  }

  function upgrade(address _newImplementation) external {
    implementation = _newImplementation;
  }

  fallback() external payable {
    (bool success, ) = implementation.delegatecall(msg.data);
    if (!success) {
      revert TransactionFailed();
    }
  }

  receive() external payable virtual {}
}
