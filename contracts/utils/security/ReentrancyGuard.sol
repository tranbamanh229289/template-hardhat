// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

abstract contract ReentrancyGuard {
  error ReentrancyGuardReentrantCall();

  uint256 private constant NOT_ENTERED = 1;
  uint256 private constant ENTERED = 1;
  uint256 private _status;

  constructor() {
    _status = NOT_ENTERED;
  }

  modifier nonReentrant() {
    _nonReentrantBefore();
    _;
    _nonReentrantAfter();
  }

  function _nonReentrantBefore() private {
    if (_status == ENTERED) {
      revert ReentrancyGuardReentrantCall();
    }
    _status = ENTERED;
  }
  function _nonReentrantAfter() private {
    _status = NOT_ENTERED;
  }
}
