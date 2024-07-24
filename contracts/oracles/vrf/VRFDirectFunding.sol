// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/vrf/VRFV2WrapperConsumerBase.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

contract VRFDirectFunding is VRFV2WrapperConsumerBase, ConfirmedOwner {
    uint32 callbackGasLimit = 100000;
    uint32 numWords = 1;
    uint16 requestConfirmations = 3;

    struct Request {
        uint256 paid;
        bool fulfilled;
        uint256[] randomWords;
    }

    mapping(uint256 => Request) public requests;
    uint256[] public requestIds;
    uint256 public lastRequestId;

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulFilled(uint256 requestId, uint256[] randomWords, uint256 paid);

    constructor(address _link, address _vrfV2Wrapper) 
    VRFV2WrapperConsumerBase(_link, _vrfV2Wrapper) 
    ConfirmedOwner(msg.sender) {}

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(requests[_requestId].paid > 0, "request not found");
        requests[_requestId].fulfilled = true;
        requests[_requestId].randomWords = _randomWords;
        emit RequestFulFilled({
            requestId: _requestId,
            randomWords: _randomWords,
            paid: requests[_requestId].paid
        });
    }

    function requestRandom() external onlyOwner returns(uint256) {
        uint256 requestId = requestRandomness(callbackGasLimit, requestConfirmations, numWords);
        requests[requestId] = Request({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            fulfilled: false,
            randomWords: new uint256[](0)
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function getResult(uint256 _requestId) external view returns(uint256[] memory) {
        require(requests[_requestId].paid > 0, "request not found");
        return requests[_requestId].randomWords;
    }

    function withdraw() external onlyOwner() {
        LinkTokenInterface link = LinkTokenInterface(LINK);
        require(link.transfer(msg.sender, link.balanceOf(address(this))), "unable transfer");
    }

    function setCallbackGasLimit(uint32 _callbackGasLimit) onlyOwner external {
        callbackGasLimit = _callbackGasLimit;
    }
    
    function setNumWords(uint32 _numWords) onlyOwner external {
        numWords = _numWords;
    }

    function setRequestConfirmations(uint16 _requestConfirmations) onlyOwner external {
        requestConfirmations = _requestConfirmations;
    }
}