// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library StorageSlot {
  struct AddressSlot {
    address value;
  }

  struct Uint256Slot {
    uint256 value;
  }

  struct BooleanSlot {
    bool value;
  }

  struct Bytes32Slot {
    bytes32 value;
  }

  struct StringSlot {
    string value;
  }

  struct BytesSlot {
    bytes value;
  }

  function getAddressSlot(
    bytes32 slot
  ) internal pure returns (AddressSlot storage r) {
    assembly ("memory-safe") {
      r.slot := slot
    }
  }

  function getUint256Slot(
    bytes32 slot
  ) internal pure returns (Uint256Slot storage r) {
    assembly ("memory-safe") {
      r.slot := slot
    }
  }
  function getBooleanSlot(
    bytes32 slot
  ) internal pure returns (BooleanSlot storage r) {
    assembly ("memory-safe") {
      r.slot := slot
    }
  }
  function getBytes32Slot(
    bytes32 slot
  ) internal pure returns (Bytes32Slot storage r) {
    assembly ("memory-safe") {
      r.slot := slot
    }
  }
  function getStringSlot(
    bytes32 slot
  ) internal pure returns (StringSlot storage r) {
    assembly ("memory-safe") {
      r.slot := slot
    }
  }
  function getBytesSlot(
    bytes32 slot
  ) internal pure returns (BytesSlot storage r) {
    assembly ("memory-safe") {
      r.slot := slot
    }
  }
}
