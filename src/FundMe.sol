// SPDX-License-Identifier: MIT
// 1. pragma
pragma solidity ^0.8.26;

// 2. Imports
import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

// 3. Contract
contract FundMe {
    using PriceConverter for uint256;

    uint256 public myCount = 0;
    uint256 public constant MINIMUM_USD = 5 * 1e18; // $5 in Wei
    address[] private s_funders;
    address private i_owner;
    AggregatorV3Interface private s_priceFeed;
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        myCount = myCount + 1;
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "Insufficient ETH sent!!");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (uint256 funderIdx = 0; funderIdx < fundersLength; funderIdx++) {
            address funder = s_funders[funderIdx];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        myCount = 0;
        (bool callsuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callsuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIdx = 0; funderIdx < s_funders.length; funderIdx++) {
            address funder = s_funders[funderIdx];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        myCount = 0;

        // transfer, send, call
        // payable(msg.sender).transfer(address(this).balance);

        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        (bool callsuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callsuccess, "Call failed");
    }

    // modifier
    modifier onlyOwner() {
        // _; execute code before require
        // require(msg.sender == i_owner, "You are not owner");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _; // execute code after require
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    /**
     * Getter (View/pure) functions
     */
    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
