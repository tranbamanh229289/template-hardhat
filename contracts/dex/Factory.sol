// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Pool} from "./Pool.sol";
import {IPool} from "../interfaces/IPool.sol";
import {Create2} from "../lib/Create2.sol";

contract Factory {
  /* Error */
  error IndenticalAddresses(address);
  error AddressIsZero();
  error PoolIsCreated();

  /* Event */
  event PoolCreated(address token0, address token1, address pool);

  /* State */
  mapping(address => mapping(address => address)) private tokenPools;

  /* Main Function */
  function createPool(address tokenA, address tokenB) external {
    if (tokenA == tokenB) {
      revert IndenticalAddresses(tokenA);
    }

    if (tokenA == address(0)) {
      revert AddressIsZero();
    }

    (address token0, address token1) = tokenA < tokenB
      ? (tokenA, tokenB)
      : (tokenB, tokenA);

    if (tokenPools[tokenA][tokenB] != address(0)) {
      revert PoolIsCreated();
    }
    bytes memory bytecode = type(Pool).creationCode;
    bytes32 salt = keccak256(abi.encodePacked(token0, token1));
    address pool = Create2.deploy(bytecode, salt);
    tokenPools[token0][token1] = pool;
    IPool(pool).initialize(token0, token1);
    emit PoolCreated(token0, token1, pool);
  }

  function getPool(
    address tokenA,
    address tokenB
  ) external view returns (address pool) {
    (address token0, address token1) = tokenA < tokenB
      ? (tokenA, tokenB)
      : (tokenB, tokenA);
    pool = tokenPools[token0][token1];
  }
}
