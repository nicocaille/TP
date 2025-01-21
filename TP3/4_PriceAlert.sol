// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceAlert {
    AggregatorV3Interface internal priceFeed;
    int public alertPrice;
    address public owner;

    event PriceThresholdMet(int currentPrice);

    constructor() {
        // BNBUSD
        priceFeed = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
        owner = msg.sender;
    }

    function setAlertPrice(int _price) public {
        require(msg.sender == owner, "Only owner");
        alertPrice = _price;
    }

    function checkPrice() public returns (bool) {
        (, int price, , , ) = priceFeed.latestRoundData();
        if (price >= alertPrice) {
            emit PriceThresholdMet(price);
            return true;
        }
        return false;
    }
}
