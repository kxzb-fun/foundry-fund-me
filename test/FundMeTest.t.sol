// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // first task: to ensure our FundMe contract operates effectively
    // setup function will deploy our contract
    uint256 number = 1;
    FundMe fundMe;
    // NOTE: why ? Error (8349): Initial value for constant variable has to be compile-time constant.
    // address constant USER = makeAddr("user");
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    address priceFeedAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    function setUp() external {
        number = 2;
        // us -> FundMeTest -> FundMe
        // fundMe = new FundMe(priceFeedAddress);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // EvmError: OutOfFunds
        vm.deal(USER, STARTING_BALANCE);
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
        // NOTE why?
        assertEq(fundMe.i_owner(), msg.sender);
        // assertEq(fundMe.i_owner(), address(this));
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailWithoutEnougthETH() public {
        vm.expectRevert("Didn't send enough ETH");
        fundMe.fund(); // <- We send 0 value
    }

    function testFundUpdatesFundDataStrucutre() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        // [FAIL. Reason: assertion failed: 0 != 10000000000000000000] testFundUpdatesFundDataStrucutre() (gas: 99169)
        // uint256 amountFunded = fundMe.getAddressToAmountFunded(msg.sender);
        // PASS
        // uint256 amountFunded = fundMe.getAddressToAmountFunded(address(this));
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
}
