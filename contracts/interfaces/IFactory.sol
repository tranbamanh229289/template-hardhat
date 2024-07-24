// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IFactory {
  function deploy(
    bytes memory _bytecode,
    bytes32 _salt
  ) external returns (address);
  function getAddress(
    bytes memory _bytecode,
    bytes32 _salt
  ) external returns (address);
}
