// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract TransparentProxy {
  error OnlyAdmin();
  error TransactionFailed();

  address public implementation;
  address public admin;

  constructor(address _implementation) {
    implementation = _implementation;
    admin = msg.sender;
  }

  modifier onlyAdmin() {
    if (msg.sender != admin) revert OnlyAdmin();
    _;
  }

  function upgrade(address _newImplementation) external onlyAdmin {
    implementation = _newImplementation;
  }

  fallback() external payable {
    (bool success, ) = implementation.delegatecall(msg.data);
    if (!success) {
      revert TransactionFailed();
    }
  }
  receive() external payable {}
}
