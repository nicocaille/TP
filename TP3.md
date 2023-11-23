# Introduction

This tutorial will introduce you to generating random numbers in Solidity smart contracts using Chainlink VRF (Verifiable Random Function). [Chainlink VRF](https://docs.chain.link/vrf) is used as a verifiable source of randomness on-chain. We will be using the Polygon (Matic) Mumbai testnet and the Remix IDE.

# Why use Chainlink VRF?

Solidity contracts are deterministic, therefore anyone who figures out how your contract produces randomness could predict its results. Chainlink VRF generates a random number off-chain with a cryptographic proof used to verify the result.

# Prerequisites

To follow this tutorial, you should have a basic understanding of Solidity [smart contracts](https://solidity-by-example.org/) & the [Remix IDE](https://remix.ethereum.org/).

# Requirements

You will need to have the [MetaMask](https://metamask.io/) browser extension installed.

# Using Chainlink VRF

## Getting testnet tokens

You will need some testnet MATIC and LINK. These can be acquired from the [Polygon Faucet](https://mumbaifaucet.com/) and the [ChainLink Faucet](https://faucets.chain.link/mumbai). MATIC token will be used to pay for contract deployment and making transactions. LINK token will be used to pay the Chainlink oracle for randomness.

You can view your current MATIC and LINK balances in Metamask or by going to https://mumbai.polygonscan.com/ & entering your address in the search bar.

To see LINK tokens in your Metamask:

- Click on the Add Token button
- Enter `0x326C977E6efc84E512bB9C30f76E30c160eD06FB` in the Token Contract Address text field. Token Symbol and Token Decimal text fields will be pre-filled when you enter the Token Contract Address.
- Click the Next button
- Click the Confirm button to add LINK tokens to your list of assets in Metamask

## Using the Remix IDE

We will use the Remix IDE - an online development environment for smart contracts, provided by the Ethereum Foundation.
Head over to https://remix.ethereum.org. Click on the File Icon to create a new file and name it `RandomNumber.sol`.

## Creating the smart contract

In `RandomNumber.sol`, copy the entire smart contract code below and paste it into the Remix editor panel.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract RandomNumber is VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;

    uint256 public randomResult;

    /**
     * Constructor inherits VRFConsumerBase
     *
     * Network: Polygon (Matic) Mumbai Testnet
     * Chainlink VRF Coordinator address: 0x8C7382F9D8f56b33781fE506E897a4F1e2d17255
     * LINK token address:                0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Key Hash: 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4
     */
    constructor()
        VRFConsumerBase(
            0x8C7382F9D8f56b33781fE506E897a4F1e2d17255, // VRF Coordinator
            0x326C977E6efc84E512bB9C30f76E30c160eD06FB  // LINK Token
        ) public
    {
        keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
        fee = 0.0001 * 10 ** 18; // 0.0001 LINK
    }

    /**
     * Requests randomness
     */
    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) > fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }
}
```

This will inherit from the VRFConsumerBase contract. The VRFConsumerBase constructor takes two parameters: An address for the VRF Coordinator and an address for the LINK Token. We will use `0x8C7382F9D8f56b33781fE506E897a4F1e2d17255` for VRF Coordinator and `0x326C977E6efc84E512bB9C30f76E30c160eD06FB` for the LINK Token which will work on the Mumbai testnet.

We will use the contract hash `0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4` to specify the Chainlink oracle to use and set the fee to 0.0001 LINK to pay the oracle for its verifiable random output.

```solidity
constructor()
    VRFConsumerBase(
        0x8C7382F9D8f56b33781fE506E897a4F1e2d17255, // VRF Coordinator
        0x326C977E6efc84E512bB9C30f76E30c160eD06FB  // LINK Token
    ) public
{
    keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
    fee = 0.0001 * 10 ** 18; // 0.0001 LINK
}
```
