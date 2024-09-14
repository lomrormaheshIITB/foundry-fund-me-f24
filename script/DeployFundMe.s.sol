// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        // Mock for priceFeed
        /**
         * whenever you put a transaction call between a vm.startBroadcast() and vm.stopBroadcast()
         * foundry has a default address 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38 which it always use to send those transactions
         * and that default address always have a default balance of 79228162514264337593543950335
         */
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
