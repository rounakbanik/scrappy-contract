//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract ScrappySquirrels is Ownable, ERC721Enumerable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    uint public constant MAX_SUPPLY = 14000;
    uint public constant MAX_PER_MINT = 5;

    string public baseTokenURI;

    uint public price = 0.05 ether;
    uint public freeMintTier = 7000;

    mapping(address => bool) freeMintDone;

    bool public saleIsActive = false;

    constructor(string memory baseURI) ERC721("Scrappy Squirrels", "SSQ") {
        setBaseURI(baseURI);
    }

    // Reserve NFTs to creator wallet
    function reserveNfts(uint _count) public onlyOwner {
        uint totalMinted = _tokenIds.current();

        require(totalMinted.add(_count) < MAX_SUPPLY, "Not enough NFTs left to reserve");

        for (uint i = 0; i < _count; i++) {
            _mintSingleNft(msg.sender);
        }
    }

    // Airdrop NFTs
    function airDropNfts(address[] calldata _wAddresses) public onlyOwner {
        uint totalMinted = _tokenIds.current();
        uint count = _wAddresses.length;

        require(totalMinted.add(count) < MAX_SUPPLY, "Not enough NFTs left to reserve");

        for (uint i = 0; i < count; i++) {
            _mintSingleNft(_wAddresses[i]);
        }
    }

    // Override empty _baseURI function 
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    // Allow owner to set baseTokenURI
    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    // Set Sale state
    function setSaleState(bool _activeState) public onlyOwner {
        saleIsActive = _activeState;
    }

    // Mint Squirrels
    function mintNfts(uint _count) public payable {

        uint totalMinted = _tokenIds.current();

        require(totalMinted.add(_count) < MAX_SUPPLY, "Not enough NFTs left!");
        require(_count >0 && _count <= MAX_PER_MINT, "Cannot mint specified number of NFTs.");
        require(saleIsActive, "Sale is not currently active!");
        
        uint cost = 0;

        if (!freeMintDone[msg.sender] && totalMinted < freeMintTier) {
            cost = price.mul(_count);
        }
        else {
            cost = price.mul(_count - 1);
            freeMintDone[msg.sender] = true;
        }

        require(msg.value >= price.mul(_count), "Not enough ether to purchase NFTs.");

        for (uint i = 0; i < _count; i++) {
            _mintSingleNft(msg.sender);
        }
    }

    // Mint a single squirrel
    function _mintSingleNft(address _wAddress) private {
        // Sanity check for absolute worst case scenario
        require(totalSupply() == _tokenIds.current(), "Indexing has broken down!");
        uint newTokenID = _tokenIds.current();
        _safeMint(_wAddress, newTokenID);
        _tokenIds.increment();
    }

    // Check if free mint is available (not minted and tier still available)
    function isFreeMintAvailable(address _wAddress) public view returns (bool) {
        uint tokenCount = _tokenIds.current();
        return !freeMintDone[_wAddress] && tokenCount < freeMintTier;
    }

    // Update price
    function updatePrice(uint _newPrice) public onlyOwner {
        price = _newPrice;
    }

    // Update free tier
    function updateFreeTier(uint _newTier) public onlyOwner {
        freeMintTier = _newTier;
    }

    // Withdraw ether
    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    // Get tokens of an owner
    function tokensOfOwner(address _owner) external view returns (uint[] memory) {

        uint tokenCount = balanceOf(_owner);
        uint[] memory tokensId = new uint256[](tokenCount);

        for (uint i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }
}