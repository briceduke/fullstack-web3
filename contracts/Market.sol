// SPDX-License-Identifier: MIT or Apache-2.0
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable private owner;
    uint256 private listPrice = 0.025 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint id;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) private idToItem;

    event MarketItemCreated (
        uint indexed id,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    function getListPrice() public view returns (uint256) {
        return listPrice;
    }

    function createMarketItem(address nftContract, uint256 tokenId, uint256 price) public payable nonReentrant {
        require(price > 0, "Price must be greater than 0");
        require(msg.value == listPrice, "Price must match list price");

        _itemIds.increment();
        uint256 id = _itemIds.current();

        idToItem[id] = MarketItem(
            id,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(id, nftContract, tokenId, msg.sender, address(0), price, false);
    }

    function createMarketSale(address nftContract, uint256 id) public payable nonReentrant {
        uint price = idToItem[id].price;
        uint tokenId = idToItem[id].tokenId;

        require(msg.value == price, "Asking price must be submitted!");

        idToItem[id].owner = payable(msg.sender);
        idToItem[id].sold = true;
        
        idToItem[id].seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        _itemsSold.increment();

        payable(owner).transfer(listPrice);
    }

    function fetchAllMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _itemIds.current();
        uint unsoldCount = _itemIds.current() - _itemsSold.current();
        uint currentIdx = 0;

        MarketItem[] memory items = new MarketItem[](unsoldCount);

        for (uint i = 0; i < itemCount; i++) {
            if (idToItem[i + 1].owner == address(0)) {
                uint currentId = i + 1;

                MarketItem storage item = idToItem[currentId];
                items[currentIdx] = item;
                currentIdx++;
            }
        }

        return items;
    }

    function fetchMyItems() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIdx = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToItem[i + 1].owner == msg.sender) {
                itemCount++;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint i = 0; i < itemCount; i++) {
            if (idToItem[i + 1].owner == msg.sender) {
                uint currentId = i + 1;

                MarketItem storage item = idToItem[currentId];
                items[currentIdx] = item;
                currentIdx++;
            }
        }

        return items;
    }

    function fetchCreatedItems() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIdx = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToItem[i + 1].seller == msg.sender) {
                itemCount++;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToItem[i + 1].seller == msg.sender) {
                uint currentId = i + 1;

                MarketItem storage item = idToItem[currentId];
                items[currentIdx] = item;
                currentIdx++;
            }
        }

        return items;
    }
}