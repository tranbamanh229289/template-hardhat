// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Counter {
  uint256 public number;
  function setNumber(uint256 _number) external {
    number = _number;
  }
  function increment() external {
    number++;
  }
}
