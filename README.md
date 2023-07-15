# OddEvenGame Contract

## Introduction

The OddEvenGame contract is a smart contract written in Solidity that allows users to participate in a betting game. The game involves guessing whether a randomly generated number is odd or even. The contract uses Chainlink's VRF (Verifiable Random Function) to generate random numbers securely.

## Contract Details

- Contract Name: OddEvenGame
- Solidity Version: 0.8.7
- License: MIT

## Dependencies

The contract relies on the following external dependencies:

- Chainlink's VRFCoordinatorV2Interface
- Chainlink's VRFConsumerBaseV2
- ConfirmedOwner

## Usage

To use the OddEvenGame contract, follow these steps:

1. Deploy the contract by providing the following parameters:

   - `_participationFee`: The participation fee required to place a bet.
   - `subscriptionId`: Your subscription ID for Chainlink's VRF service.
   - `coordinator`: The address of the VRFCoordinatorV2 contract.
   - `_keyHash`: The key hash used for generating random numbers.

2. Place a bet by calling the `placeBet` function:

   - `isOdd`: A boolean value indicating whether the bet is for an odd number.

3. Request random words by calling the `requestRandomWords` function. This can only be done by the contract owner.

4. Once the random words are fulfilled, the `fulfillRandomWords` function will be called internally to determine the result of the bet.

5. Check if you are a winner by calling the `checkWinner` function.

6. Withdraw your winnings by calling the `withdraw` function.

7. To start a new bet, the contract owner can call the `resetAndStartNewBet` function.

## Events

The OddEvenGame contract emits the following events:

- `RequestSent(uint256 requestId, uint32 numWords)`: Indicates that a request for random words has been sent.
- `RequestFulfilled(uint256 requestId, uint256[] randomWords)`: Indicates that the request for random words has been fulfilled.

## Contract Variables

The OddEvenGame contract has the following public variables:

- `players`: An array of addresses representing the participants in the game.
- `bets`: A mapping of addresses to their corresponding bet amounts.
- `betIsOdd`: A mapping of addresses to a boolean indicating whether their bet is for an odd number.
- `totalPot`: The total amount of funds in the contract.
- `oddPlayers`: The number of players who have bet on an odd number.
- `evenPlayers`: The number of players who have bet on an even number.
- `eachUserWithdrawable`: The amount that each winning user can withdraw.
- `isFulfilled`: A boolean indicating whether the random number generation has been fulfilled.

## Functions

The OddEvenGame contract provides the following functions:

### `placeBet(bool isOdd) public payable`

Allows a user to place a bet by specifying whether the bet is for an odd number (`isOdd`).

### `requestRandomWords() external onlyOwner returns (uint256 requestId)`

Requests random words from Chainlink's VRF service. This function can only be called by the contract owner.

### `fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override`

Internal function called when the random words are fulfilled. Determines the result of the bet.

### `checkWinner() public view returns (bool)`

Checks if the caller is a winner by comparing their bet with the generated random number.

### `withdraw() external`

Allows a winning user to withdraw their winnings.

### `resetAndStartNewBet() external onlyOwner`

Resets the contract state and starts a new bet. This function can only be called by the contract owner.

## License

This contract is licensed under the MIT License. You can find the license text in the SPDX-License-Identifier comment at the beginning of the contract.

## Contract deployed to Sepolia testnet:

Contract address: 0x3fCd113fc4Ae3819F28B036243aCe79a05f1f467

Link: https://sepolia.etherscan.io/address/0x3fCd113fc4Ae3819F28B036243aCe79a05f1f467
