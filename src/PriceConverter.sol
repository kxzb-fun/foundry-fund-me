// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice() internal view returns (uint256) {
        // from this url get address  https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1
        // address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        (
            ,
            /* uint80 roundId */ int256 answer /* uint256 startedAt */ /* uint256 updatedAt */ /* uint80 answeredInRound */,
            ,
            ,

        ) = priceFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getConvertionRate(
        uint256 ethAmount
    ) internal view returns (uint256) {
        // 1 ETH ?
        // 2000_1*10*18
        uint256 ethPrice = getPrice();
        //  2000_1*10*18 *  1*10*18 / 1*10*18
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        // $2000 = 1 ETH
        return ethAmountInUsd;
    }

    function getVersion() internal view returns (uint256) {
        return
            AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
                .version();
    }
}
