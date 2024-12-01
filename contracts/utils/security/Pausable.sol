// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract Pausable is AccessControl {
  error OnlyOperator();

  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;
  bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

  modifier onlyOperator() {
    if (!hasRole(OPERATOR_ROLE, msg.sender)) {
      revert OnlyOperator();
    }
    _;
  }

  constructor(address adminRole) {
    _paused = false;
    _grantRole(DEFAULT_ADMIN_ROLE, adminRole);
  }

  function _pause() internal virtual onlyOperator {
    _paused = true;
    emit Paused(msg.sender);
  }

  function _unpause() internal virtual onlyOperator {
    _paused = false;
    emit Unpaused(msg.sender);
  }

  function emergencyWithdraw() external virtual onlyOperator {
    if (address(this).balance > 0) {
      payable(msg.sender).transfer(address(this).balance);
    }
  }
}
