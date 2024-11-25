// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Pool {
  /* Error */
  error ForBidden();
  /* Event */

  /* Struct */

  /* State */
  address public token0;
  address public token1;

  uint128 private reserve0;
  uint128 private reserve1;
  uint256 private lastTimestamp;

  function initialize(address _token0, address _token1) external {
    if (token0 != address(0)) {
      revert ForBidden();
    }

    token0 = _token0;
    token1 = _token1;
  }

  function addLiquidity() external {}

  function removeLiquidity() external {}
}
