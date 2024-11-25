// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library Math {
  function sqrt(uint256 a) internal pure returns (uint256 x) {
    if (a > 3) {
      x = a / 2;
      uint256 y = a / 4 + 1;
      while (y < x) {
        x = y;
        y = (x + a / x) / 2;
      }
    } else {
      x = 0;
      if (a != 0) {
        x = 1;
      }
    }
  }
}
