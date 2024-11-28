// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Pausable {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;

  constructor() {
    _paused = false;
  }

  function _pause() internal virtual {
    _paused = true;
    emit Paused(msg.sender);
  }

  function _unpause() internal virtual {
    _paused = false;
    emit Unpaused(msg.sender);
  }
}
