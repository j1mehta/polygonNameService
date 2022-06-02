//SPDX-License-Identifier: Unlicensed

pragma solidity^0.8.10;

import "hardhat/console.sol";
import {StringUtils} from "../libraries/StringUtils.sol";

contract Domains {

    //Top level domain like .eth
    string public tld;

    mapping(string => address) public domains;

    mapping(string => string) public records;

    constructor(string memory _tld) {
        tld = _tld;
        console.log("Top Level Domain: %s", _tld);
    }

    function price (string calldata name) public pure returns (uint) {
        uint len = StringUtils.strlen(name);
        require (len > 0, "String length zero");
        if (len == 3) {
            return 5 * 10**16; //0.05 MATIC since 10**18 is 1 MATIC
        } else if (len == 4){
            return  3 * 10**16;
        } else {
            return 1 * 10**16;
        }
    }

    //And this my friends is a payable function. This is the power of blockchain where we added payments without
    //any fancy API or auth. Smoooooth!!! When we call this fn through our run.js, we simpy put in the amount
    //as the second argument
    function register(string calldata name) public payable {

        //We only mention storage location for array, struct or mapping type which are reference type variables.
        //uint is value type, ie, value of these varibales are copied ev
        uint _price = price(name);

        //Require to have enough funds to cover the price
        require(msg.value > _price, "Funds not enough.");


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