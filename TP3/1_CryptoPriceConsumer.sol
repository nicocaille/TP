// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract CryptoPriceConsumer {
    AggregatorV3Interface internal priceFeed;

    // Adresse du Price Feed BNB/USD sur BNB Chain Testnet
    constructor() {
        priceFeed = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
    }

    function getLatestPrice() public view returns (int) {
        (
            ,
            /* uint80 roundID */ int price,
            ,
            ,

        ) = /* uint startedAt */ /* uint timeStamp */ /* uint80 answeredInRound */
            priceFeed.latestRoundData();
        return price;
    }

    function getDecimals() public view returns (uint8) {
        return priceFeed.decimals();
    }
}
