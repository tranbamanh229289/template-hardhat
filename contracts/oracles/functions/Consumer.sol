//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

contract Trigger is FunctionsClient, AccessControl {
  using FunctionsRequest for FunctionsRequest.Request;

  /* Error */
  error UnexpectedRequestId(bytes32 requestId);
  error ActiveWillInvalid();

  /* Event */
  event Response(bytes32 indexed requestId, bytes response, bytes err);

  /* State variable */
  bytes32 public constant REQUEST_ROLE = keccak256("REQUEST_ROLE");
  bytes32 public lastRequestId;
  bytes public lastResponse;
  bytes public lastError;

  bytes public encryptedSecretUrls;
  bytes32 public donID;
  uint32 public gasLimit;
  uint64 public subscriptionId;
  string public source;
  mapping(bytes32 => address) requestWills;
  mapping(address => bool) willRouters;

  modifier onlyAdmin() {
    _checkRole(DEFAULT_ADMIN_ROLE);
    _;
  }
  constructor(
    address router_,
    bytes32 donID_,
    uint32 gaslimit_,
    uint64 subscriptionId_,
    bytes memory encryptedSecretUrls_,
    string memory source_
  ) FunctionsClient(router_) {
    donID = donID_;
    gasLimit = gaslimit_;
    subscriptionId = subscriptionId_;
    encryptedSecretUrls = encryptedSecretUrls_;
    source = source_;
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  function setInfoRequest(
    bytes32 donID_,
    uint32 gasLimit_,
    uint64 subscriptionId_
  ) external onlyAdmin {
    donID = donID_;
    gasLimit = gasLimit_;
    subscriptionId = subscriptionId_;
  }

  function setWillRouter(address willRouter_) external onlyAdmin {
    _grantRole(REQUEST_ROLE, willRouter_);
  }

  function setEncryptedSecretUrls(
    bytes calldata encryptedSecretUrls_
  ) external onlyAdmin {
    encryptedSecretUrls = encryptedSecretUrls_;
  }

  function setSource(string calldata source_) external onlyAdmin {
    source = source_;
  }

  function sendRequest(
    string[] calldata args,
    address will
  ) external onlyRole(REQUEST_ROLE) returns (bytes32) {
    FunctionsRequest.Request memory req;
    req.initializeRequestForInlineJavaScript(source);
    req.addSecretsReference(encryptedSecretUrls);
    if (args.length > 0) req.setArgs(args);

    bytes32 requestId = _sendRequest(
      req.encodeCBOR(),
      subscriptionId,
      gasLimit,
      donID
    );
    lastRequestId = requestId;
    requestWills[requestId] = will;

    return requestId;
  }

  function fulfillRequest(
    bytes32 requestId,
    bytes memory response,
    bytes memory err
  ) internal override {
    if (lastRequestId != requestId) {
      revert UnexpectedRequestId(requestId);
    }
    lastResponse = response;
    lastError = err;
    emit Response(requestId, response, err);
  }
}
