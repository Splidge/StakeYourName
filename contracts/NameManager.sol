// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "interfaces/ENS_Registry.sol";
import "interfaces/ENS_BaseRegistrar.sol";
import "interfaces/ENS_BulkRenewal.sol";
import "interfaces/ENS_Resolver.sol";

/// @title StakeYourName - NameManager
/// @notice Maintains a list of users and names they want to keep renewed
/// @notice Can check for name expiry and pay for renewals
/// @author Daniel Chilvers

contract NameManager is Ownable {
    /// @dev can probably remove ensRegistryAddress as it can be discovered from the Registrar
    address internal ensRegistryAddress = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;
    address internal baseRegistrarAddress = 0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85;
    address internal bulkRenewalAddress = 0xfF252725f6122A92551A5FA9a6b6bf10eb0Be035;
    uint256 internal renewalPeriod = 28 days; 

    BaseRegistrar ensReg;
    ENS ens;
    BulkRenewal ensBulkRenewal;
    ENSResolver ensResolver;

    /// @dev map user address to arrays of their names and expiry times
    mapping (address => uint256[]) names;

    /// @dev map names to the users that are funding them
    mapping (uint256 => address[]) users;

    uint256[] nameList;

    constructor() {
        ensReg = BaseRegistrar(baseRegistrarAddress);
        ens = ENS(ensReg.ens());
        ensBulkRenewal = BulkRenewal(bulkRenewalAddress);
        
    }

    function checkPrice(string[] memory _names, uint256 _duration) public view returns(uint256) {
        return (ensBulkRenewal.rentPrice(_names, _duration));
    }

    function uintArrayToStringsArray(uint256[] memory _ints) public pure returns(string[] memory){
        string[] memory _strings = new string[](_ints.length);    
        for (uint i; i < _ints.length; i++){
            uint256 _i = _ints[i];
            if (_i == 0) {
                _strings[i] = "0";
            }
            uint j = _i;
            uint len;
            while (j != 0) {
                len++;
                j /= 10;
            }
            bytes memory bstr = new bytes(len);
            uint k = len - 1;
            while (_i != 0) {
                bstr[k--] = byte(uint8(48 + _i % 10));
                _i /= 10;
            }
            _strings[i] = string(bstr);
        }
        return _strings;
    }

    function checkForRenewals() public view returns(uint256[] memory, uint256){
        uint256 _count = countRenewals();
        uint256 _price;
        uint256[] memory _names = new uint256[](_count);
        uint256 _j;
        for (uint i; i < nameList.length; i++) {
            if(renewalDue(nameList[i])) {
                _names[_j] = nameList[i];
                _j++;
            }
        }
        checkPrice(uintArrayToStringsArray(_names), renewalPeriod);
        return (_names, _price);
    }

    function countRenewals() internal view returns (uint256){
        uint256 _count;
        for (uint i; i < nameList.length; i++) {
            if(renewalDue(nameList[i])) {
                _count++;
            }
        }
        return (_count);
    }


    /*
    *
    *   User and name related functions
    *
    */

    /// @dev records msg.sender as a funder of _name
    /// @dev and records _name as funded by msg.sender
    /// @dev adds to the list of names we're overseing
    function addRecord(uint256 _name) public {
        bool _exists;
        uint256 _index;
        (_exists, _index) = checkForUser(_name);
        if (_exists == false) {
            users[_name].push(msg.sender);
        }

        (_exists, _index) = checkForName(_name);
        if (_exists == false) {
            names[msg.sender].push(_name);
            //names[msg.sender].expiry.push();
        }
        bool _found = false;
        for (uint i; i < nameList.length; i++){
            if(nameList[i] == _name){
                _found = true;
                break;
            }
        }
        if (_found = false) {
            nameList.push(_name);
        }

    }

    /// @dev Removes from users the record matching _name
    /// @dev Removes from names the record matching msg.sender
    /// @dev Removes from list of names we're overseing IF nobody else is funding it
    function removeRecord(uint256 _name) public {
        bool _exists = false;
        uint256 _index;
        (_exists, _index) = checkForUser(_name);
        if (_exists == true) {
            users[_name][_index] = users[_name][users[_name].length-1];
            users[_name].pop();
        }

        (_exists, _index) = checkForName(_name);
        if (_exists == true) {
            names[msg.sender][_index] = names[msg.sender][names[msg.sender].length-1];
            names[msg.sender].pop();
        }

        if(users[_name].length == 0){
            for (uint i; i < nameList.length; i++){
                if (nameList[i] == _name) {
                    nameList[i] = nameList[nameList.length-1];
                    nameList.pop();
                    break;
                }
            }
        }
    }

    /// @dev check if msg.sender is already funding _name
    function checkForName(uint256 _name) public view returns(bool, uint256) {
        bool _found = false;
        uint256 _index = 0;
        for (uint i; i < names[msg.sender].length; i++){
            if(names[msg.sender][i] == _name){
                _index = i;
                _found = true;
                break;
            }
        }
        return (_found, _index);
    }   

    /// @notice returns the number of users funding _name
    function countFunders(uint256 _name) public view returns(uint256){
        return users[_name].length;
    }

    function countNames() public view returns(uint256){
        return nameList.length;
    }

    /// @dev checks if msg.sender is already funding _name
    function checkForUser(uint256 _name) public view returns(bool, uint256) {
        bool _found = false;
        uint256 _index = 0;
        for (uint i; i < users[_name].length; i++){
            if(users[_name][i] == msg.sender){
                _index = i;
                _found = true;
                break;
            }
        }
        return (_found, _index);
    }

    /*
    *
    *   ENS Related Functions
    *
    */

    /// @notice pass in either the _name or _nameHash to resolve an address
    function resolveName(string calldata _name, bytes32 _nameHash) public returns(address){
        if (_nameHash == 0){
            _nameHash = computeNamehash(_name);
        }
        ensResolver =  ENSResolver(ens.resolver(_nameHash));
        return(ensResolver.addr(_nameHash));
    }

    function renewalDue(uint256 _labelhash) public view returns(bool) {
        return (getNameExpiry(_labelhash) <= block.timestamp - renewalPeriod);
    }

    function updateRenewalPeriod(uint256 _time) public onlyOwner {
        renewalPeriod = _time;
    }

    // @notice Update registrar and/or associated registry
    // @dev Hopefully never needed
    function updateRegistrar(address _address) external onlyOwner {
        ensReg = BaseRegistrar(_address);
        ens = ENS(ensReg.ens());
    } 
    function updateBulkRenewal(address _address) external onlyOwner {
        ensBulkRenewal = BulkRenewal(_address);
    } 
    // @dev make me internal once testing is done
    function getNameExpiry(uint256 _name) public view returns(uint256){
        return ensReg.nameExpires(_name);
    }

    // @notice find out which contracts we're talking to
    function returnEnsAddress() public view returns(address){
        return address(ens);
    }
    function returnEnsRegAddress() public view returns(address){
        return address(ensReg);
    }
    function returnBulkRenewalAddress() public view returns(address){
        return address(ensBulkRenewal);
    }
    /// @dev always fails on testnet because they didn't impletment bulk renewal there
    function checkRegistryMatches() public view returns(bool){
        return (ensReg.ens() == ensBulkRenewal.ens());
    }

    /// @notice funtions to help out with ENS integration
    function convertBytesToUint(bytes32 _bytes) public pure returns(uint256){
        uint256 _uint = uint256(_bytes);
        return (_uint);
    }
    function convertUintToBytes(uint256 _uint) public pure returns(bytes32){
        bytes32 _bytes = bytes32(_uint);
        return (_bytes);
    }
    // @dev this could be expensive, lets do this off-chain where possible
    function computeNamehash(string calldata _name) public pure returns (bytes32 namehash) {
        namehash = 0x0000000000000000000000000000000000000000000000000000000000000000;
        namehash = keccak256(abi.encodePacked(namehash, keccak256(abi.encodePacked('eth'))));
        namehash = keccak256(abi.encodePacked(namehash, keccak256(abi.encodePacked(_name))));
    }
    function computeLabelhash(string calldata _name) public pure returns (bytes32 namehash) {
        namehash = keccak256(abi.encodePacked(_name));
    }

}
