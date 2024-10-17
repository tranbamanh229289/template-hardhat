// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IERC721 {
  function balanceOf(address owner) external view returns (uint256 balance);
  function ownerOf(uint256 tokenId) external view returns (address owner);
  function approve(address to, uint256 tokenId) external;
  function transferFrom(address from, address to, uint256 tokenId) external;
  function safeTransferFrom(address from, address to, uint256 tokenId) external;
}
