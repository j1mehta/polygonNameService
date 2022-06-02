//SPDX-License-Identifier: Unlicensed

pragma solidity^0.8.10;

import "hardhat/console.sol";

contract Domains {
    mapping(string => address) public domains;

    mapping(string => string) public records;

    constructor() {
        console.log("Init domains contract");
    }

    function register(string calldata name) public {
        //Here we’re checking that the address of the domain you’re trying to register
        //is the same as the zero address. The zero address in Solidity is sort of like the void (in the literal
        //sense) where everything comes from. When an address mapping is initialized, all entries in it point to the
        //zero address. So if a domain hasn’t been registered, it’ll point to the zero address!
        require(domains[name] == address(0));

        domains[name] = msg.sender;
        console.log("%s has registered a domain", msg.sender);
    }

    function getAddress(string calldata name) public view returns (address) {
        return domains[name];
    }

    function setRecord(string calldata name, string calldata record) public {
        require(domains[name] == msg.sender);
        records[name] = record;
    }

    function getRecord(string calldata name) public view returns(string memory) {
        return records[name];
    }

}