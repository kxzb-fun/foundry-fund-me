// Get funds from users
// Withdraw funds
// Set a minmum fundinng value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// Custom Errors in Solidity https://soliditylang.org/blog/2021/04/21/custom-errors/
error NotOwner();

contract FundMe {
    // allow user to send $
    // have a minimun $ send

    using PriceConverter for uint256;
    // Immutability and constants
    uint256 public constant MINIMUN_USD = 5e18;
    address[] private s_funders;
    mapping(address funder => uint256 amountFuned)
        private s_addressToAmountFunded;

    address private immutable i_owner;

    AggregatorV3Interface private s_priceFeed;

    // when contract init run this code
    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        // 1. how do we sent ETH to this contract
        // 1 ether = 1000000000000000000 wei = 1*10**18 wei = 1e18 wei
        // require(msg.value > 1e18, "Didn't send enough ETH");
        // require(msg.value > 1 ether, "Didn't send enough ETH");
        // require(getConvertionRate(msg.value) >= MINIMUN_USD, "Didn't send enough ETH");
        require(
            msg.value.getConvertionRate(s_priceFeed) >= MINIMUN_USD,
            "Didn't send enough ETH"
        );
        // msg.sender
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] =
            s_addressToAmountFunded[msg.sender] +
            msg.value;
    }

    function withdrawCheaper() public onlyOwner {
        uint256 s_fundersLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < s_fundersLength;
            funderIndex++
        ) {
            // get s_funders address
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset array
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call fail");
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            // get s_funders address
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset array
        s_funders = new address[](0);
        // withdraw the funds
        // https://solidity-by-example.org/sending-ether/  transfer send call

        // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send fail");
        // call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call fail");
    }

    modifier onlyOwner() {
        // first solution
        // require(i_owner == msg.sender, "Must be owner!");
        // section solution
        // FIXED: i write i_owner == msg.sender before
        if (i_owner != msg.sender) {
            revert NotOwner();
        }
        _;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    // what happens if somebody send this contract ETH without calling the fund function?
    // two  sepesceil function receive() fallback()
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /** Getter Functions */
    function getAddressToAmountFunded(
        address fundingAddress
    ) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }
}
