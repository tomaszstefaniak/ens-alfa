// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

contract EnsName {
    using ERC165Checker for address;

    uint256 public itemCount;

    struct Item{
        uint256 itemId;
        string name;
        uint256 tokenId;
        uint256 price;
        bool listed;
        address payable seller;
        address tokenContract;
    }

    mapping(uint256 => Item) public items;

    //Function to list the item for sale, approve this contract
    function listENS(string memory _name, uint256 _tokenId, uint256 _price, address _tokenContract) public{
        require(_price > 0, "Price should be greater than 0");
        require(_tokenContract.supportsInterface(type(IERC1155).interfaceId), "Token contract must be ERC1155");
        itemCount++;
        items[itemCount] = Item(
            itemCount,
            _name,
            _tokenId,
            _price,
            true,
            payable(msg.sender),
            _tokenContract
        );
    }

    //Function to buy the ENS - ie - transferFrom or safeTransferFrom
    function buyENS(uint256 _itemId) public payable{
        Item memory eachItem = items[_itemId];
        require(msg.value >= eachItem.price, "Price sent is not correct");
        require(_itemId > 0 && _itemId <= itemCount, "Wrong itemId");
        require(eachItem.listed == true, "This item is has not been listed for sale");
        IERC1155(eachItem.tokenContract).safeTransferFrom(eachItem.seller, msg.sender, eachItem.tokenId, 1, "");
        eachItem.listed = false;
        (bool sent, ) = eachItem.seller.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable{}

}
