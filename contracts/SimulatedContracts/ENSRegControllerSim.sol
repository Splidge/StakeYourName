// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IENSSim.sol";

contract ENSRegControllerSim is Ownable {
    address ensAddress = address(0);
    uint256 renewPrice = 118496123;
    uint256 balance = 0;
    
    mapping (uint256 => uint256) expiry;
    uint256[] names;

    constructor(address _ensAddress){
        ensAddress = _ensAddress;
        IENSSim ensSim = IENSSim(_ensAddress);
        ensSim.updateRegController(address(this));
    }

    // Simulated functions
    function ens() public view returns(address){
        return (ensAddress);
    }
    function renew(string calldata _id, uint256 _duration) public payable {
        require(msg.value >= _duration * renewPrice);
        uint256 _cost = _duration * renewPrice;
        string memory _eth;
        _eth = "eth";
        bytes32 nameHash = computeHash(_id,computeHash(_eth, bytes32(0x0)));
        uint256 uintNameHash = convertBytesToUint(nameHash);
        bool _exists = false;
        for (uint256 i; i < names.length; i++){
            if(names[i] == uintNameHash){
                _exists = true;
            }
        }
        if(_exists = false){
            require(false, "name not found");
        } else {
            expiry[uintNameHash] = expiry[uintNameHash] + _duration;
            balance = balance + _cost;
            msg.sender.transfer(address(this).balance - balance);
        }
    }

    function rentPrice(string memory _name, uint256 _duration) public view returns(uint256){
        _name;
        uint256 _cost = _duration * renewPrice;
        return (_cost);
    }


    // admin functions
    function expires(uint256 _id) public view returns(uint256){
        return (expiry[_id]);
    }
    function withdraw() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }
    function updateENS(address _ensAddress) public {
        ensAddress = _ensAddress;
    }
    /// either adds, updates or removes a name
    function updateName(uint256 _name, uint256 _expiry) public {
        if(_expiry != 0){
            bool _exists = false;
            for (uint256 i; i < names.length; i++){
                if(names[i] == _name){
                    expiry[_name] = _expiry;
                    _exists = true;
                }

            }
            if (_exists == false){
                names.push(_name);
                expiry[_name] = _expiry; 
            }
        } else {
            for (uint256 i; i < names.length; i++){
                if(names[i] == _name){
                    names[i] = names[names.length-1];
                    names.pop();
                }

            }
        }
        
    }
    function day() public {
        for (uint256 i; i < names.length; i++){
            expiry[names[i]] = expiry[names[i]] - 1 days;
        }
    }
    function month() public {
        for (uint256 i; i < names.length; i++){
            expiry[names[i]] = expiry[names[i]] - 28 days;
        }
    }

    function convertBytesToUint(bytes32 _bytes) public pure returns(uint256){
        uint256 _uint = uint256(_bytes);
        return (_uint);
    }
    function convertUintToBytes(uint256 _uint) public pure returns(bytes32){
        bytes32 _bytes = bytes32(_uint);
        return (_bytes);
    }

    function computeHash(string memory _subdomain, bytes32 _name) public pure returns (bytes32 namehash) {
        namehash = keccak256(abi.encodePacked(_name, keccak256(abi.encodePacked(_subdomain))));
    }

    function retrieveETH() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

}