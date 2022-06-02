//SPDX-License-Identifier: Unlicensed

pragma solidity^0.8.10;

import "hardhat/console.sol";
import {StringUtils} from "../libraries/StringUtils.sol";

//The "@" used in below import instead of using a file path simply denotes a mapping where
//the key @openzeppelin is mapped to a file path where openzeppelin library is installed. For more info,
//checkout how imports work in solidity
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import {Base64} from "../libraries/Base64.sol";

contract Domains is ERC721URIStorage{

    // NFT's unique identifier that means
    // *using fns of library Counters as type Counters.Counter"*
    // It's a syntactic sugar
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // We'll be storing our NFT images on chain as SVGs
    string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><path fill="url(#B)" d="M0 0h270v270H0z"/><defs><filter id="A" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path d="M72.863 42.949c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-10.081 6.032-6.85 3.934-10.081 6.032c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-8.013-4.721a4.52 4.52 0 0 1-1.589-1.616c-.384-.665-.594-1.418-.608-2.187v-9.31c-.013-.775.185-1.538.572-2.208a4.25 4.25 0 0 1 1.625-1.595l7.884-4.59c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v6.032l6.85-4.065v-6.032c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595L41.456 24.59c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-14.864 8.655a4.25 4.25 0 0 0-1.625 1.595c-.387.67-.585 1.434-.572 2.208v17.441c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l10.081-5.901 6.85-4.065 10.081-5.901c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v9.311c.013.775-.185 1.538-.572 2.208a4.25 4.25 0 0 1-1.625 1.595l-7.884 4.721c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-7.884-4.59a4.52 4.52 0 0 1-1.589-1.616c-.385-.665-.594-1.418-.608-2.187v-6.032l-6.85 4.065v6.032c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l14.864-8.655c.657-.394 1.204-.95 1.589-1.616s.594-1.418.609-2.187V55.538c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595l-14.993-8.786z" fill="#fff"/><defs><linearGradient id="B" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#cb5eee"/><stop offset="1" stop-color="#0cd7e4" stop-opacity=".99"/></linearGradient></defs><text x="32.5" y="231" font-size="27" fill="#fff" filter="url(#A)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string svgPartTwo = '</text></svg>';


    //Top level domain like .eth
    string public tld;

    mapping(string => address) public domains;

    mapping(string => string) public records;

    constructor(string memory _tld)
    //Below, we initialize the name and symbol for the NFT collection where each NFT will have its own token_ID. This
    //is indirect initialization done to the constructor of the base class from which the contract is derived, ie,
    //ERC721. If you don't do this, you'll get an error asking you to mark the contract "Domain" as abstract
    //due to the missing implementation of ERC721 contract's constructor.
    ERC721("Polygon Name Service","PNS"){
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

        //Here we’re checking that the address of the domain you’re trying to register
        //is the same as the zero address. The zero address in Solidity is sort of like the void (in the literal
        //sense) where everything comes from. When an address mapping is initialized, all entries in it point to the
        //zero address. So if a domain hasn’t been registered, it’ll point to the zero address!
        require(domains[name] == address(0));

        //Require to have enough funds to cover the price
        require(msg.value > _price, "Funds not enough.");

        // Combine the name passed into the function  with the TLD
        // Strings are weird in Solidity. We need the function `encodePacked` that first "encodes" the string to bytes
        // and then "packs" them together to form a single string.
        string memory _name = string(abi.encodePacked(name, ".", tld));

        // Create the SVG (image) for the NFT with the name
        string memory finalSvg = string(abi.encodePacked(svgPartOne, _name, svgPartTwo));

        uint256 newRecordId = _tokenIds.current();
        uint256 length = StringUtils.strlen(name);
        string memory strLen = Strings.toString(length);

        console.log("Registering %s.%s on the contract with tokenID %d", name, tld, newRecordId);

        // Create the JSON metadata of our NFT. We do this by combining strings through encodePacked and encoding
        // the combination to base64 characters since that's the encoding best suited for corruptionless data transfer
        string memory json = Base64.encode(
            abi.encodePacked(
            '{"name": "',
            _name,
            '", "description": "A domain on the Ninja name service", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(finalSvg)),
            '","length":"',
            strLen,
            '"}'
            )
        );

        string memory finalTokenUri = string( abi.encodePacked("data:application/json;base64,", json));

        console.log("\n--------------------------------------------------------");
        console.log("Final tokenURI", finalTokenUri);
        console.log("--------------------------------------------------------\n");

        _safeMint(msg.sender, newRecordId);
        _setTokenURI(newRecordId, finalTokenUri);
        domains[name] = msg.sender;

        console.log("%s has registered a domain", msg.sender);
        _tokenIds.increment();
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