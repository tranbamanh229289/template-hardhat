// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library Create2 {
  error BytecodeIsEmpty();
  error AddressIsZero();

  /**
   * @dev deploy new smart contract
   * @param bytecode  bytecode contract
   * @param salt  salt byte
   */
  function deploy(
    bytes memory bytecode,
    bytes32 salt
  ) internal returns (address addr) {
    if (bytecode.length == 0) {
      revert BytecodeIsEmpty();
    }
    addr = _deploy(bytecode, salt);
    if (addr == address(0)) {
      revert AddressIsZero();
    }
    return addr;
  }

  /**
   * @dev get address contract
   * @param bytecode  bytecode contract
   * @param salt  salt byte
   */
  function getAddress(
    bytes memory bytecode,
    bytes32 salt
  ) internal view returns (address addr) {
    return _getAddress(keccak256(bytecode), salt, address(this));
  }

  /**
   * @dev compute address
   * @param bytecodeHash  bytecode hash
   * @param salt salt byte
   * @param deployer deployer address
   * @return addr keccak256(0xFF,deployer,salt,keccak256(bytecodeHash))
   */
  function _getAddress(
    bytes32 bytecodeHash,
    bytes32 salt,
    address deployer
  ) internal pure returns (address addr) {
    assembly ("memory-safe") {
      let ptr := mload(0x40)
      mstore(add(ptr, 0x40), bytecodeHash)
      mstore(add(ptr, 0x20), salt)
      mstore(ptr, deployer)
      mstore8(add(ptr, 0x0b), 0xff)
      addr := and(
        keccak256(add(ptr, 0x0b), 85),
        0xffffffffffffffffffffffffffffffffffffffff
      )
    }
  }

  /**
   * @dev create contract
   * @param bytecode  bytecode
   * @param salt  salt byte
   */
  function _deploy(
    bytes memory bytecode,
    bytes32 salt
  ) internal returns (address addr) {
    assembly ("memory-safe") {
      addr := create2(0, add(bytecode, 20), mload(bytecode), salt)
      if and(iszero(addr), not(iszero(returndatasize()))) {
        revert(0, 0)
      }
    }
  }
}
1
1
