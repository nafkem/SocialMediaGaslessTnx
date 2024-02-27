// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./";

contract SMFactoryContract {
    YourERC721Token public nftContract;

    constructor(address _nftContract) {
        nftContract = YourERC721Token(_nftContract);
    }

    function createContent(string memory tokenURI) external {
        uint256 tokenId = nftContract.totalSupply() + 1;
        nftContract.mint(msg.sender, tokenId, tokenURI);
    }
}
