// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./SMToken.sol";

contract SocialMedia {
    address public nftFactoryContract;
    mapping(address => bool) private _authenticatedUsers;
    mapping(uint256 => address) private _groupOwners;
    mapping(uint256 => address[]) private _groupMembers;
    mapping(uint256 => string[]) private _nftComments;
    uint256 private _tokenIdCounter;

    event ContentCreated(address indexed creator, uint256 indexed tokenId, string tokenURI);
    event GroupCreated(address indexed owner, uint256 indexed groupId);
    event CommentAdded(uint256 indexed tokenId, address indexed commenter, string content);
    event GaslessTransactionExecuted(address indexed user, address indexed relayer, bytes functionCall);

    modifier onlyAuthenticated() {
        require(_authenticatedUsers[msg.sender], "User not authenticated");
        _;
    }

    constructor(address _nftFactoryContract) {
        nftFactoryContract = _nftFactoryContract;
    }

    function authenticateUser() external {
        _authenticatedUsers[msg.sender] = true;
    }

    function createContent(string memory tokenURI) external onlyAuthenticated {
        uint256 tokenId = _getNextTokenId();
        require(IERC721(nftFactoryContract).mint(msg.sender, tokenId, tokenURI), "NFT minting failed");
        emit ContentCreated(msg.sender, tokenId, tokenURI);
    }

    function createGroup() external onlyAuthenticated {
        uint256 groupId = _generateGroupId();
        _groupOwners[groupId] = msg.sender;
        _groupMembers[groupId].push(msg.sender);
        emit GroupCreated(msg.sender, groupId);
    }

    function addMemberToGroup(uint256 groupId, address member) external onlyAuthenticated {
        require(msg.sender == _groupOwners[groupId], "Not group owner");
        _groupMembers[groupId].push(member);
    }

    function addComment(uint256 tokenId, string memory content) external onlyAuthenticated {
        _nftComments[tokenId].push(content);
        emit CommentAdded(tokenId, msg.sender, content);
    }

    function getComments(uint256 tokenId) external view returns (string[] memory) {
        return _nftComments[tokenId];
    }

    function executeGaslessTransaction(bytes calldata signature, bytes calldata functionCall) external {
        address signer = _recoverSigner(signature, functionCall);
        require(_authenticatedUsers[signer], "Invalid signature");
        (bool success, ) = address(this).delegatecall(functionCall);
        require(success, "Gasless transaction execution failed");

        emit GaslessTransactionExecuted(signer, msg.sender, functionCall);
    }

    function _getNextTokenId() private returns (uint256) {
        _tokenIdCounter++;
        return _tokenIdCounter;
    }

    function _generateGroupId() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.prevrandao))) % 1000000;
    }

    function _recoverSigner(bytes memory signature, bytes memory functionCall) private pure returns (address) {
        bytes32 hash = keccak256(functionCall);
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        return ecrecover(hash, v, r, s);
    }
}
