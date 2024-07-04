// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on a local Anvil, we deploy the mocks
    // Else, grab the existing address from the live network
    NetworkConfig public activeNetowrkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 200e8;

    constructor() {
        // https://chainlist.org/?testnets=true&search=sepolia
        if (block.chainid == 11155111) {
            activeNetowrkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetowrkConfig = getMainnetEthConfig();
        } else {
            activeNetowrkConfig = getOrCreateAnvilEthConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetConfig;
    }

    // Error (2527): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
    // function getOrCreateAnvilEthConfig() public pure returns
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // Not set a new one, if the address not a 0 that say we already set it
        if (activeNetowrkConfig.priceFeed != address(0)) {
            return activeNetowrkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
