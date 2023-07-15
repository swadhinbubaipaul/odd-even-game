// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract OddEvenGame is VRFConsumerBaseV2, ConfirmedOwner {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    VRFCoordinatorV2Interface immutable COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    bytes32 immutable keyHash;
    // 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;

    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 1;

    uint256 internal fee;
    uint256 public randomResult;
    address[] public players;
    mapping(address => uint256) public bets;
    mapping(address => bool) public betIsOdd;
    uint256 public totalPot;
    uint256 public oddPlayers;
    uint256 public evenPlayers;
    uint256 public eachUserWithdrawable;
    bool public isFulfilled;

    constructor(
        uint256 _participationFee,
        uint64 subscriptionId,
        address coordinator,
        bytes32 _keyHash
    ) VRFConsumerBaseV2(coordinator) ConfirmedOwner(msg.sender) {
        COORDINATOR = VRFCoordinatorV2Interface(coordinator);
        s_subscriptionId = subscriptionId;
        fee = _participationFee;
        keyHash = _keyHash;
    }

    function placeBet(bool isOdd) public payable {
        require(msg.value > 0, "Bet amount must be greater than 0");
        require(bets[msg.sender] == 0, "Already placed bet");
        require(
            msg.value + totalPot <= address(this).balance,
            "Contract does not have enough funds to cover the bet"
        );
        players.push(msg.sender);
        bets[msg.sender] = msg.value;
        betIsOdd[msg.sender] = isOdd;
        if (isOdd) {
            oddPlayers++;
        } else {
            evenPlayers++;
        }
        totalPot += msg.value;
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords()
        external
        onlyOwner
        returns (uint256 requestId)
    {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        randomResult = _randomWords[0];
        bool isOdd = randomResult % 2 == 1;
        if (isOdd) {
            eachUserWithdrawable = totalPot / oddPlayers;
            oddPlayers = 0;
        } else {
            eachUserWithdrawable = totalPot / evenPlayers;
            evenPlayers = 0;
        }
        isFulfilled = true;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    function checkWinner() public view returns (bool) {
        require(bets[msg.sender] == fee, "Not participated in betting");
        require(isFulfilled, "Bet is not drawn yet");
        bool isOdd = randomResult % 2 == 1;
        return betIsOdd[msg.sender] == isOdd;
    }

    function withdraw() external {
        require(checkWinner(), "You are not winner");
        totalPot -= eachUserWithdrawable;
        bets[msg.sender] = 0;
        betIsOdd[msg.sender] = false;
        payable(msg.sender).transfer(eachUserWithdrawable);
    }

    function resetAndStartNewBet() external onlyOwner {
        for (uint256 i; i < players.length; i++) {
            bets[players[i]] = 0;
            betIsOdd[players[i]] = false;
        }
        players = new address[](0);
        randomResult = 0;
        isFulfilled = false;
        totalPot = 0;
        oddPlayers = 0;
        evenPlayers = 0;
        eachUserWithdrawable = 0;
        if (address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }
}
