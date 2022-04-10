// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract silo is ERC1155 {

    address dai;

    struct Item
    {
        uint price;
        uint supply;
        address issuerHolder;
    }

    struct Issuer
    {
        string name;
        uint UID;
        address addressIssuer;
        string companyInfo;
        uint typeItem;
        mapping(uint => Item) item;
    }

    uint numIssuer = 0;
    mapping(uint => Issuer) public issuer;

    constructor(address _dai) ERC1155("https://ipfs.io/ipfs/QmUEyQ2jf5Gf4WxUApGiLbzuiWCoZxnMuGzoqhQpH2tf2x/{id}.json")
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

        numIssuer++;
    }

    function create(uint _UIDIssuer, uint _typeItem, uint _price, uint _supply) public
    {
        require
        (
            issuer[_UIDIssuer].addressIssuer == msg.sender,
            "Your are not the owner of the Issuer ! You can't do this action."
        );

        issuer[_UIDIssuer].item[_typeItem].price = _price;
        issuer[_UIDIssuer].item[_typeItem].issuerHolder = msg.sender;
        issuer[_UIDIssuer].item[_typeItem].supply += _supply;

    }

//ajouter partie URI et changer ERC721
    function buy(uint  _UIDIssuer, uint _typeItem, uint _supply) public
    {
        uint value = _supply * issuer[_UIDIssuer].item[_typeItem].price * 10 ** 18;

        require
        (
            issuer[_UIDIssuer].item[_typeItem].supply >= _supply,
            "You ask for too much: please check the current available supply !"
        );

        require
        (
            IERC20(dai).balanceOf(msg.sender) >= value,
            "You don't have enough money !"
        );

        IERC20(dai).transferFrom(msg.sender, issuer[_UIDIssuer].addressIssuer, value);
        issuer[_UIDIssuer].item[_supply].supply -= _supply;
        _mint(msg.sender, issuer[_UIDIssuer].UID, _supply, ""); // a modif

    }

    function sell(string memory _name) public
    {
        //
    }

    //SETTER

    function changePrice(uint _UIDIssuer, uint _typeItem, uint _newPrice) public payable
    {
        require
        (
            issuer[_UIDIssuer].addressIssuer == msg.sender,
            "Your are not the owner of the Issuer ! You can't do this action."
        );

        issuer[_UIDIssuer].item[_typeItem].price = _newPrice;
    }

    function changeSupply(uint _UIDIssuer, uint _typeItem, uint _newSupply) public payable
    {
        require
        (
            issuer[_UIDIssuer].addressIssuer == msg.sender,
            "Your are not the owner of the Issuer ! You can't do this action."
        );

        issuer[_UIDIssuer].item[_typeItem].supply = _newSupply;
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

    function getItem(uint _UID, uint _item) public view returns(Item memory)
    {
        return issuer[_UID].item[_item];
    }

}
