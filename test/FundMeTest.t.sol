// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    // first task: to ensure our FundMe contract operates effectively
    // setup function will deploy our contract
    uint256 number = 1;
    FundMe fundMe;

    function setUp() external {
        number = 2;
        // us -> FundMeTest -> FundMe
        fundMe = new FundMe();
    }

    function testDemo() public view {
        assertEq(number, 2);
        // forge test -vv
        console.log(number);
        console.log("Hello, world!");
    }

    function testMinimumDollarIsFive() public view {
        // NOTE： call external public variable use getter function call
        assertEq(fundMe.MINIMUN_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public view {
        console.log(fundMe.i_owner());
        console.log(msg.sender);
        // assertEq(fundMe.i_owner(), msg.sender);
        assertEq(fundMe.i_owner(), address(this));
    }
}
