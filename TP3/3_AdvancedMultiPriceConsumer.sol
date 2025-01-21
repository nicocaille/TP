// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract AdvancedMultiPriceConsumer {
    AggregatorV3Interface internal bnbUsdPriceFeed;
    AggregatorV3Interface internal btcUsdPriceFeed;
    AggregatorV3Interface internal ethUsdPriceFeed;

    mapping(string => AggregatorV3Interface) public priceFeeds;

    constructor() {
        priceFeeds["BNB"] = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
        priceFeeds["BTC"] = AggregatorV3Interface(
            0x5741306c21795FdCBb9b265Ea0255F499DFe515C
        );
        priceFeeds["ETH"] = AggregatorV3Interface(
            0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7
        );
    }

    struct PriceData {
        int price;
        uint8 decimals;
        uint256 timestamp;
    }

    function getPriceData(
        string memory symbol
    ) public view returns (PriceData memory) {
        require(
            address(priceFeeds[symbol]) != address(0),
            "Prix non disponible"
        );

        AggregatorV3Interface priceFeed = priceFeeds[symbol];
        (, int price, , uint256 timestamp, ) = priceFeed.latestRoundData();

        return PriceData(price, priceFeed.decimals(), timestamp);
    }

    function convertPrice(
        string memory fromSymbol,
        string memory toSymbol,
        int256 amount
    ) public view returns (int256) {
        PriceData memory fromPrice = getPriceData(fromSymbol);
        PriceData memory toPrice = getPriceData(toSymbol);

        return (amount * fromPrice.price) / toPrice.price;
    }
}
