// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {StorageSlot} from "../../lib/StorageSlot.sol";

library ERC1967 {
  //keccak256("eip1967.proxy.implementation") - 1
  bytes32 public constant IMPLEMENT_SLOT =
    0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  //keccak256("eip1967.proxy.admin") - 1
  bytes32 public constant ADMIN_SLOT =
    0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  //keccak256("eip1967.proxy.beacon") - 1
  bytes32 public constant BEACON_SLOT =
    0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

  error ERC1967InvalidImplementation();
  error ERC1967InvalidAdmin();
  error ERC1967InvalidBeacon();

  function getImplementation() internal view returns (address) {
    return StorageSlot.getAddressSlot(IMPLEMENT_SLOT).value;
  }

  function setImplementation(address implementation) private {
    if (implementation.code.length == 0) {
      revert ERC1967InvalidImplementation();
    }
    StorageSlot.getAddressSlot(IMPLEMENT_SLOT).value = implementation;
  }

  function getAdmin() internal view returns (address) {
    return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
  }

  function setAdmin(address admin) private {
    if (admin == address(0)) {
      revert ERC1967InvalidAdmin();
    }
    StorageSlot.getAddressSlot(ADMIN_SLOT).value = admin;
  }

  function getBeacon() internal view returns (address) {
    return StorageSlot.getAddressSlot(BEACON_SLOT).value;
  }

  function setBeacon(address beacon) private {
    if (beacon.code.length == 0) {
      revert ERC1967InvalidBeacon();
    }
    StorageSlot.getAddressSlot(BEACON_SLOT).value = beacon;
  }
}
