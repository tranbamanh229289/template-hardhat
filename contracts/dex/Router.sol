// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../interfaces/IFactory.sol";
import "./Pool.sol";

contract Router {
  /* Error */
  error TokenInvalid();
  /* Event */
  event CreatedPool(
    address indexed token0,
    address indexed token1,
    address pool
  );
  /* Struct */

  /* State */
  IFactory public immutable factory;

  /* Constructor */
  constructor(address _factory) {
    factory = IFactory(_factory);
  }

  /* Main Function */

  function createPool(
    address _token0,
    address _token1
  ) external returns (address) {
    if (_token0 == _token1) revert TokenInvalid();
    (address token0, address token1) = _token0 > _token1
      ? (_token0, _token1)
      : (_token1, _token0);
    bytes32 salt = keccak256(abi.encodePacked(token0, token1));
    address pool = factory.deploy(type(Pool).creationCode, salt);
    emit CreatedPool(token0, token1, pool);
    return pool;
  }

  function getPool(
    address _token0,
    address _token1
  ) external returns (address) {
    bytes32 salt = keccak256(abi.encodePacked(_token0, _token1));
    address pool = factory.getAddress(type(Pool).creationCode, salt);
    return pool;
  }
}
