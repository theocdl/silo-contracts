// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DAI is ERC20
{
    address silo;
    address owner = msg.sender;

    constructor()
    public ERC20("Magic DAI for hackers", "DAI")
    {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }

    event Withdrawn(address user, uint amount);

    function withdraw() public
    {
        _mint(msg.sender, 50 * 10 ** 18);
        emit Withdrawn(msg.sender, 50);
    }

    function approveSilo(uint _value) public
    {
        uint value = _value * 10 ** 18;
        approve(silo, value);
    }

    function changeSiloAddress(address _silo) public
    {
        require
        (
            msg.sender == owner,
            "Only the owner of the contract can call this function."
        );
        silo = _silo;
    }
}