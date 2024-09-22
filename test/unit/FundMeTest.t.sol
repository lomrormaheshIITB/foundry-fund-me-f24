// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user"); // create a address
    uint256 constant SEND_VALUE = 0.1 ether; // 1e15 = $2
    uint256 constant STARTING_BALANCE = 7 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // SetUp function is called before every test automatically
        console.log("Hello from SetUp!");
        // Deploy the fundMe contract
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
        // console.log("PRANK USER:", USER);
    }

    function testDemo() public pure {
        console.log("Hello from testDemo!");
    }

    function testMinimumDollarIsFive() public view {
        console.log("Hello from testMinimumDollarIsFive!");
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() public view {
        console.log("Hello from testOwner!");
        console.log("fundMe:", address(fundMe));
        // us -> FundMeTest (address(this)) -> DeployFundMe (foundry's default address is used to create the fundMe contract) -> fundMe
        // i_owner is msg.sender, who is msg.sender ? msg.sender is foundry's default address
        assertEq(fundMe.getOwner(), msg.sender);
        assertEq(fundMe.myCount(), 0);
    }

    // What can we do to work with addresses outside our system?
    // 1. Unit
    //     - Testing a specific part of our code
    // 2. Integration
    //     - Testing how our code works with other parts of our code
    // 3. Forked
    //     - Testing our code on a simulated real environment
    // 4. Staging
    //     - Testing our code in a real environment this is not prod

    function testPriceFeedVersionIsAccurate() public view {
        console.log("Hello from testPriceFeedVersionIsAccurate!");
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    // Modular Deployment - Done
    // Modular Testing - Done

    function testFundFailsWithoutEnoughEth() public {
        console.log("Hello from testFundFailsWithoutEnoughEth!");
        // SetUp the revert expectation
        vm.expectRevert("Insufficient ETH sent!!");

        // Call the `fund` function with Insufficient ETH (less than $5)
        uint256 ethAmount = 0.001 * 1e18; // 1ETH = $2000; $2 = 0.001 ETH
        fundMe.fund{value: ethAmount}(); // should Revert
    }

    function testFundUpdatesFundedDataStructures() public {
        console.log("Hello from testFundUpdatesFundedDataStructures!!");
        vm.prank(USER); // The next tx is sent by USER
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testAddsFundersToArrayOfFunders() public funded {
        console.log("Hello from testAddsFundersToArrayOfFunders!!");
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        console.log("Hello from testOnlyOwnerCanWithdraw!!");
        // The USER is not owner, owner is msg.sender (msg.sender is foundry's default address due to use of vm.startBroadcast() )
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log("Gas Used:", gasUsed);
        // console.log("gasStart:", gasStart);
        // console.log("gasEnd:", gasEnd);
        // console.log("gasprice:", tx.gasprice);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawWithMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i <= numberOfFunders; i++) {
            // vm.prank a new address
            // vm.deal a new address
            hoax(address(i), SEND_VALUE);
            // fund the fundMe
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assertEq(fundMe.getOwner().balance, startingOwnerBalance + startingFundMeBalance);
        assertEq(address(fundMe).balance, 0);
    }

    function testWithdrawWithMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i <= numberOfFunders; i++) {
            // vm.prank a new address
            // vm.deal a new address
            hoax(address(i), SEND_VALUE);
            // fund the fundMe
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        assertEq(fundMe.getOwner().balance, startingOwnerBalance + startingFundMeBalance);
        assertEq(address(fundMe).balance, 0);
    }
}
