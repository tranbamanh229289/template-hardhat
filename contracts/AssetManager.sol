// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "./interfaces/IERC20.sol";
import {IERC721} from "./interfaces/IERC721.sol";
import {AccessGuard} from "./access/AccessGuard.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract AssetManager is AccessGuard, ReentrancyGuard {
  /* Error */
  /* Event */
  event Deposit(address user, uint256 balance, uint256 timestamp);
  event Withdraw(address user, uint256 balance, uint256 timestamp);

  /* Struct */
  struct Asset {
    uint256 balance;
    uint256 startTime;
    uint256 modifyTime;
    AssetType assetType;
  }

  struct DepositParams {
    uint256 balance;
    AssetType assetType;
  }

  struct WithDrawParams {
    uint256 balance;
    AssetType assetType;
  }

  /* Enum */
  enum AssetType {
    ETH,
    ERC20,
    ERC721
  }
  /* State */
  IERC20 erc20;
  IERC721 erc721;
  mapping(address => Asset) public assets;

  /* Constructor */
  constructor() {}

  /* Modifier */

  /* Main Function */
  function deposit() external payable nonReentrant {}

  function withdraw() external nonReentrant {}

  receive() external payable {}
}
