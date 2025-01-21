// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract AdvancedPriceAlert {
    AggregatorV3Interface internal priceFeed;
    address public owner;

    struct Alert {
        int upperLimit;
        int lowerLimit;
        bool isActive;
        uint256 lastTriggered;
        uint256 cooldownPeriod;
    }

    mapping(address => Alert) public userAlerts;

    event AlertTriggered(
        address user,
        int currentPrice,
        int upperLimit,
        int lowerLimit,
        uint256 timestamp
    );

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function setAlert(
        int _upperLimit,
        int _lowerLimit,
        uint256 _cooldownPeriod
    ) external {
        require(_upperLimit > _lowerLimit, "Limites invalides");
        userAlerts[msg.sender] = Alert({
            upperLimit: _upperLimit,
            lowerLimit: _lowerLimit,
            isActive: true,
            lastTriggered: 0,
            cooldownPeriod: _cooldownPeriod
        });
    }

    function checkPriceAlert() external returns (bool) {
        Alert storage alert = userAlerts[msg.sender];
        require(alert.isActive, "Alerte non active");
        require(
            block.timestamp >= alert.lastTriggered + alert.cooldownPeriod,
            "Periode de recharge non ecoulee"
        );

        (, int price, , uint256 timestamp, ) = priceFeed.latestRoundData();

        if (price >= alert.upperLimit || price <= alert.lowerLimit) {
            alert.lastTriggered = block.timestamp;
            emit AlertTriggered(
                msg.sender,
                price,
                alert.upperLimit,
                alert.lowerLimit,
                timestamp
            );
            return true;
        }
        return false;
    }

    function getPrice() public view returns (int, uint8) {
        (, int price, , , ) = priceFeed.latestRoundData();
        return (price, priceFeed.decimals());
    }

    function deactivateAlert() external {
        userAlerts[msg.sender].isActive = false;
    }

    function updateCooldownPeriod(uint256 _newPeriod) external {
        userAlerts[msg.sender].cooldownPeriod = _newPeriod;
    }
}
