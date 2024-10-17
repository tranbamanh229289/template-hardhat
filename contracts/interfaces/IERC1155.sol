// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IERC1155 {
  function balanceOf(address account, uint256 id) external returns (uint256);
  function safeTransferFrom(
    address from,
    uint256 to,
    uint256 value,
    bytes calldata data
  ) external;
}
