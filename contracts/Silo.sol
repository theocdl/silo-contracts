// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract silo is ERC721,ERC721URIStorage  {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    address dai;

    struct Item
    {
        uint price;
        uint supply;
        address issuerHolder;
        string URI;
    }

    struct Issuer
    {
        string name;
        uint UID;
        address addressIssuer;
        string companyInfo;
        uint numItem;
        mapping(uint => Item) item;
    }

    uint numIssuer = 0;
    mapping(uint => Issuer) public issuer;

    constructor(address _dai) ERC721("SiloToken", "SLO")
    {
        dai = _dai;
    }

    function addIssuer(string memory _name, string memory _companyInfo) public payable
    {
        bool verify = false;
        // to verify if the Issuer already exists

        for (uint i = 0; i < numIssuer; i++) {

            if (keccak256(abi.encodePacked(issuer[i].name)) == keccak256(abi.encodePacked(_name))) {
                verify = true;
            }
        }

        require(
            verify == false,
            "Your Issuer has already been created !"
        );
        //verifier coord entreprise//
        issuer[numIssuer].name = _name;
        issuer[numIssuer].UID = numIssuer;
        issuer[numIssuer].addressIssuer = msg.sender;
        issuer[numIssuer].companyInfo = _companyInfo;
        issuer[numIssuer].numItem = 0;

        numIssuer++;
    }

    function create(uint _UIDIssuer, uint _supply, uint _price, string calldata _URI) public
    {
        require
        (
            issuer[_UIDIssuer].addressIssuer == msg.sender,
            "Your are not the owner of the Issuer ! You can't do this action."
        );

        uint numberOfItemStart = issuer[_UIDIssuer].numItem;

        for( uint i = numberOfItemStart ; i < (numberOfItemStart + _supply) ; i++)
        {
            issuer[_UIDIssuer].item[i].price = _price;
            issuer[_UIDIssuer].item[i].issuerHolder = msg.sender;
            issuer[_UIDIssuer].item[i].supply = 1;
            issuer[_UIDIssuer].item[i].URI = _URI;
        }
        issuer[_UIDIssuer].numItem += _supply;
    }

    //ajouter partie URI
    function buy(uint  _UIDIssuer) public payable
    {
        require
        (
            issuer[_UIDIssuer].numItem -1 >= 0,
            "No more item for this compagny"
        );

        uint numItem = issuer[_UIDIssuer].numItem -1;
        uint value = issuer[_UIDIssuer].item[numItem].price * 10 ** 18;

        require
        (
            issuer[_UIDIssuer].numItem > 0,
            "There is no more certificate for this compagny"
        );

        require
        (
            IERC20(dai).balanceOf(msg.sender) >= value,
            "You don't have enough money !"
        );


        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        IERC20(dai).transferFrom(msg.sender, issuer[_UIDIssuer].addressIssuer, value);

        issuer[_UIDIssuer].numItem -= 1;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, issuer[_UIDIssuer].item[numItem].URI);
        //delete issuer[_UIDIssuer].item[numItem];

    }

    function sell(string memory _name) public
    {
        //
    }

    //SETTER

    function changePrice(uint _UIDIssuer, uint _newPrice) public payable
    {
        require
        (
            issuer[_UIDIssuer].addressIssuer == msg.sender,
            "Your are not the owner of the Issuer ! You can't do this action."
        );

        for (uint i = 0 ; i < issuer[_UIDIssuer].numItem ; i++)
        {
            issuer[_UIDIssuer].item[i].price = _newPrice;
        }
    }


    function changeCompagnyInfo(uint _UIDIssuer, string memory _compagnyInfo) public payable
    {
        require
        (
            issuer[_UIDIssuer].addressIssuer == msg.sender,
            "Your are not the owner of the Issuer ! You can't do this action."
        );

        issuer[_UIDIssuer].companyInfo = _compagnyInfo;
    }

    //GETTER

    function getUidIssuer(string calldata _name) public view returns (string memory)
    {
        for (uint i = 0; i < numIssuer; i++) {
            if (keccak256(abi.encodePacked(issuer[i].name)) == keccak256(abi.encodePacked(_name))) {
                return Strings.toString(issuer[i].UID);
            }
        }
        return "Name not recognized";
    }


    function _burn(uint tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    //For Hardhat

    function getItem(uint _UIDIssuer) public view returns(Item memory)
    {
        uint numItem = issuer[_UIDIssuer].numItem - 1;

        return issuer[_UIDIssuer].item[numItem];
    }
}
