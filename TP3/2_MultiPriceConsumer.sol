// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract MultiPriceConsumer {
    AggregatorV3Interface internal bnbUsdPriceFeed;
    AggregatorV3Interface internal btcUsdPriceFeed;

    constructor() {
        bnbUsdPriceFeed = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
        btcUsdPriceFeed = AggregatorV3Interface(
            0x5741306c21795FdCBb9b265Ea0255F499DFe515C
        );
    }

    function getBNBPrice() public view returns (int) {
        (, int price, , , ) = bnbUsdPriceFeed.latestRoundData();
        return price;
    }

    function getBTCPrice() public view returns (int) {
        (, int price, , , ) = btcUsdPriceFeed.latestRoundData();
        return price;
    }
}
