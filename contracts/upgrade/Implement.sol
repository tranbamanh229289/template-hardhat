// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Proxy {
  uint256 data;

  function setData(uint256 _data) external {
    data = _data;
  }

  function getData() external returns (uint256) {
    return data;
  }
}
