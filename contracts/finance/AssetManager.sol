// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract AssetManager is
  ReentrancyGuard,
  Initializable,
  AccessControlUpgradeable
{
  /* Error */
  error NotEnoughETH();
  error NotEnoughWithdraw();
  error NotEnoughTimeWithdraw();

  /* Event */
  event Deposit(
    address user,
    address asset,
    AssetType assetType,
    uint256 amount,
    uint256 depositeTime,
    uint256 timestamp
  );

  event Withdraw(
    address user,
    address asset,
    AssetType assetType,
    uint256 amount,
    uint256 timestamp
  );

  event DepositETH(address user, uint256 amount, uint256 timestamp);

  event WithdrawETH(address user, uint256 amount, uint256 timestamp);

  /* Struct */
  struct DepositParam {
    address asset;
    address user;
    uint256 amount;
    uint256 depositTime;
    AssetType assetType;
  }

  struct WithdrawParam {
    uint256 amount;
    address asset;
    AssetType assetType;
  }

  struct ERC20Asset {
    uint256 amount;
    uint256 depositTime;
    uint256 modifiedTime;
  }

  struct ERC721Asset {
    address user;
    uint256 depositTime;
    uint256 modifiedTime;
  }

  /* Enum */
  enum AssetType {
    ERC20,
    ERC721,
    ERC1155
  }

  /* State */
  mapping(address user => uint256 amount) public ethAssets;
  mapping(address asset => mapping(address => ERC20Asset)) public erc20Asset;
  mapping(address asset => mapping(uint256 tokenId => ERC721Asset))
    public erc721Asset;

  /* Constructor */
  function initialize() public initializer {}

  /* Modifier */

  /* Main Function */
  function deposit(
    DepositParam calldata depositParam
  ) external payable nonReentrant {
    if (depositParam.assetType == AssetType.ERC20) {
      ERC20Asset storage asset = erc20Asset[depositParam.asset][msg.sender];
      asset.amount += depositParam.amount;
      asset.depositTime = depositParam.depositTime;
      asset.modifiedTime = block.timestamp;

      transferFromERC20(
        depositParam.asset,
        msg.sender,
        address(this),
        depositParam.amount
      );
    } else if (depositParam.assetType == AssetType.ERC721) {
      ERC721Asset storage asset = erc721Asset[depositParam.asset][
        depositParam.amount
      ];
      asset.user = msg.sender;
      asset.depositTime = depositParam.depositTime;
      asset.modifiedTime = block.timestamp;

      transferFromERC721(
        depositParam.asset,
        msg.sender,
        address(this),
        depositParam.amount
      );
    }

    emit Deposit(
      msg.sender,
      depositParam.asset,
      depositParam.assetType,
      depositParam.amount,
      depositParam.depositTime,
      block.timestamp
    );
  }
  function withdraw(
    WithdrawParam calldata withdrawParam
  ) external nonReentrant {
    if (withdrawParam.assetType == AssetType.ERC20) {
      ERC20Asset storage asset = erc20Asset[withdrawParam.asset][msg.sender];
      if (asset.amount < withdrawParam.amount) {
        revert NotEnoughWithdraw();
      }
      if (asset.depositTime + asset.modifiedTime > block.timestamp) {
        revert NotEnoughTimeWithdraw();
      }

      asset.amount = asset.amount - withdrawParam.amount;
      asset.modifiedTime = block.timestamp;

      releaseERC20(withdrawParam.asset, msg.sender, withdrawParam.amount);
    } else if (withdrawParam.assetType == AssetType.ERC721) {
      ERC721Asset storage asset = erc721Asset[withdrawParam.asset][
        withdrawParam.amount
      ];
      if (asset.depositTime + asset.modifiedTime > block.timestamp) {
        revert NotEnoughTimeWithdraw();
      }
      asset.modifiedTime = block.timestamp;
      releaseERC721(withdrawParam.asset, msg.sender, withdrawParam.amount);
    }

    emit Withdraw(
      msg.sender,
      withdrawParam.asset,
      withdrawParam.assetType,
      withdrawParam.amount,
      block.timestamp
    );
  }

  receive() external payable {
    if (msg.value > 0) {
      ethAssets[msg.sender] += msg.value;
      emit DepositETH(msg.sender, msg.value, block.timestamp);
    }
  }

  function withdrawETH(uint256 amount) external nonReentrant {
    if (amount > ethAssets[msg.sender]) {
      revert NotEnoughETH();
    }
    ethAssets[msg.sender] -= amount;
    payable(msg.sender).transfer(amount);
    emit WithdrawETH(msg.sender, amount, block.timestamp);
  }

  function transferFromERC20(
    address token,
    address from,
    address to,
    uint256 amount
  ) internal {
    SafeERC20.safeTransferFrom(IERC20(token), from, to, amount);
  }

  function transferFromERC721(
    address token,
    address from,
    address to,
    uint256 tokenId
  ) internal {
    IERC721(token).safeTransferFrom(from, to, tokenId);
  }

  function releaseERC20(address token, address to, uint256 amount) internal {
    SafeERC20.safeTransfer(IERC20(token), to, amount);
  }

  function releaseERC721(address token, address to, uint256 tokenId) internal {
    IERC721(token).safeTransferFrom(address(this), to, tokenId);
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external returns (bytes4) {
    return this.onERC721Received.selector;
  }
}
