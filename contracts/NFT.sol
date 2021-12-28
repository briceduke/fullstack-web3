// SPDX-License-Identifier: MIT or Apache-2.0
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFT is ERC721URIStorage {
	using Counters for Counters.Counter;
	Counters.Counter private _tokenIds;
	address private contractAddr;

	constructor(address mktAddress) ERC721("Brice Tokens", "BRIC") {
		contractAddr = mktAddress;
	}

	function createToken(string memory tokenURI) public returns (uint256) {
		_tokenIds.increment();
		uint256 newId = _tokenIds.current();

		_mint(msg.sender, newId);
		_setTokenURI(newId, tokenURI);
		setApprovalForAll(contractAddr, true);

		return newId;
	}
}
