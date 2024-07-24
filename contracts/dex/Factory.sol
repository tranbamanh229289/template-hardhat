// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Factory {
  /* Error */
  error BytecodeInvalid();

  /* Event */

  /* Struct */

  /* State */

  /* Main Function */
  function deploy(
    bytes memory _bytecode,
    bytes32 _salt
  ) external returns (address) {
    address addr = _create(_bytecode, _salt);
    return addr;
  }

  function getAddress(
    bytes memory _bytecode,
    bytes32 _salt
  ) external view returns (address) {
    bytes32 bytecodeHash = keccak256(_bytecode);
    address addr = _computedAddress(bytecodeHash, _salt, address(this));
    return addr;
  }

  // function getAddress(bytes memory _bytecode, uint256 _salt) external returns(address) {
  //     bytes32 hash = keccak256(bytes1(0xff), address(this), _salt, keccak256(_bytecode));
  //     return address(uint160(uint256(hash)));
  // }

  function _computedAddress(
    bytes32 _bytecodeHash,
    bytes32 _salt,
    address _deployer
  ) internal pure returns (address addr) {
    assembly {
      let ptr := mload(0x40)
      mstore(add(ptr, 0x40), _bytecodeHash)
      mstore(add(ptr, 0x20), _salt)
      mstore(ptr, _deployer)
      let start := add(ptr, 0x0b)
      mstore8(start, 0xff)
      addr := and(
        keccak256(start, 85),
        0xffffffffffffffffffffffffffffffffffffffff
      )
    }
  }

  function _create(
    bytes memory _bytecode,
    bytes32 _salt
  ) internal returns (address addr) {
    if (_bytecode.length == 0) {
      revert BytecodeInvalid();
    }

    assembly {
      addr := create2(
        callvalue(),
        add(_bytecode, 0x20),
        mload(_bytecode),
        _salt
      )
      if iszero(extcodesize(addr)) {
        revert(0, 0)
      }
    }
  }
}
