// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/ERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";

contract certificate is ERC1155 {

    address dai;

    struct  Issuer
    {
        string name;
        uint UID;
        address addressIssuer;

        uint supply;
        uint price;
    }

    uint numIssuer = 0;
    mapping(uint => Issuer) public issuer;


    constructor(address _dai) ERC1155("https://ipfs.io/ipfs/QmUEyQ2jf5Gf4WxUApGiLbzuiWCoZxnMuGzoqhQpH2tf2x/{id}.json")
    {
        dai = _dai;
    }

    function addIssuer(string memory _name) public payable
    {
        bool verify = false; // to verify if the Issuer already exists

        for (uint i = 0; i < numIssuer ; i++){

            if (keccak256(abi.encodePacked (issuer[i].name)) == keccak256(abi.encodePacked(_name))){
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
        issuer[numIssuer].supply = 0;
        issuer[numIssuer].price = 0;

        numIssuer++;
    }

    function createCertificate(uint _UIDIssuer, uint _supply, uint _price ) public
    {
        uint value = _supply * _price * 10**18 ;

        require
        (
            issuer[_UIDIssuer].addressIssuer == msg.sender,
            "Your are not the owner of the Issuer ! You can't do this action."
        );

        require
        (
            IERC20(dai).balanceOf(msg.sender) >= value * 3/2, //Verifier que l'entreprise à 1,5x la somme au cas ou si probleme de vente
            "You don't have enough money for create certificate ! You need to have 2 time the price on your wallet"
        );
        issuer[_UIDIssuer].supply += _supply;
        issuer[_UIDIssuer].price = _price;
    }

    function buyCertificate(uint _userSupply, uint _UIDIssuer) public
    {
        uint value = _userSupply * issuer[_UIDIssuer].price * 10**18 ;

        require
        (
            issuer[_UIDIssuer].supply >= _userSupply,
            "You ask for too much: please check the current available supply !"
        );

        require
        (
            IERC20(dai).balanceOf(msg.sender) >= value,
            "You don't have enough money !"
        );


        IERC20(dai).approve(msg.sender, value);
        IERC20(dai).transferFrom(msg.sender, issuer[_UIDIssuer].addressIssuer, value);
        issuer[_UIDIssuer].supply -= _userSupply;
        _mint(msg.sender, issuer[_UIDIssuer].UID, _userSupply, ""); //a voir si on en fait supply ou supply *10**18

    }

    function sellCertifaicateToOwnerIssuer(string memory _name) public
    {
        //
    }

    //SETTER

    function changePrice(uint _UIDIssuer, uint _newPrice) public payable
    {
        uint value = issuer[_UIDIssuer].supply * _newPrice * 10**18 ;

        require
        (
            issuer[_UIDIssuer].addressIssuer == msg.sender,
            "Your are not the owner of the Issuer ! You can't do this action."
        );

        require
        (
            IERC20(dai).balanceOf(msg.sender) >= value * 3/2, //Verifier que l'entreprise à 1,5x la somme au cas ou si probleme de vente
            "You don't have enough money for create certificate ! You need to have 2 time the price on your wallet"
        );

        issuer[_UIDIssuer].price = _newPrice;
    }

    function changeSupply(uint _UIDIssuer, uint _newSupply) public payable
    {
        require
        (
            issuer[_UIDIssuer].addressIssuer == msg.sender,
            "Your are not the owner of the Issuer ! You can't do this action."
        );

        issuer[_UIDIssuer].supply = _newSupply;
    }

    //GETTER

    function getUidIssuer(string calldata _name)public view returns(string memory)
    {
        for (uint i = 0; i < numIssuer ; i++){
            if (keccak256(abi.encodePacked (issuer[i].name)) == keccak256(abi.encodePacked(_name))){
                return Strings.toString(issuer[i].UID);
            }
        }
        return "Name not recognized";
    }

    function getInfoCertificate(uint _UIDIssuer) public view returns(string memory,uint, uint)
    {
        return (issuer[_UIDIssuer].name, issuer[_UIDIssuer].supply , issuer[_UIDIssuer].price );
    }

    function getValue(uint _UIDIssuer, uint _userSupply) public view returns(uint)
    {
        uint value = _userSupply * issuer[_UIDIssuer].price * 10**18 ;
        return value;
    }
}
