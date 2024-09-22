// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI
        // AggregatorV3Interface s_priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (, int256 price,,,) = priceFeed.latestRoundData();
        // Price of 1ETH in terms of USD
        // 2000 0000 0000 (8decimals)
        // price * 1e10 = price is in Wei (msg.value is in wei)
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // ethAmount = K_10^18
        // 1 ETH ? = $2000 = 2000_10^18
        // $2000 = (2000_10^18 * 1e18) / 1e18
        uint256 ethPrice = getPrice(priceFeed); // 2000_00000_00000_00000_000 = 1ETH
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; // Both in Wei => Wei^2 / Wei = Wei
        return ethAmountInUsd;
    }
}
