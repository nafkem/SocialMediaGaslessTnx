// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./SMToken.sol";

contract SocialMediaFactory {
    address[] public communities;
    string private constant DEFAULT_NAME = "Social Media Community";
    string private constant DEFAULT_SYMBOL = "SMC";

    function createCommunity() external {
        SMToken newCommunity = new SMToken(DEFAULT_NAME, DEFAULT_SYMBOL);
        address newTokenAddress = address(newCommunity);

        // new community to the array
        communities.push(newTokenAddress);
    }

    function getCommunities() external view returns (address[] memory) {
        return communities;
    }
}
