// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ENS_Registry.sol";
import "./interfaces/ENS_BaseRegistrar.sol";
import "./interfaces/ENS_BulkRenewal.sol";
import "./interfaces/ENS_Resolver.sol";
import "./interfaces/ENS_RegistrarController.sol";

/// @title StakeYourName - NameManager
/// @notice Maintains a list of users and names they want to keep renewed
/// @notice Can check for name expiry and pay for renewals
/// @author Daniel Chilvers


contract NameManager is Ownable {
    /// @dev can probably remove ensRegistryAddress as it can be discovered from the Registrar
    address internal ensRegistryAddress = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;
    address internal baseRegistrarAddress = 0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85;
    address internal bulkRenewalAddress = 0xfF252725f6122A92551A5FA9a6b6bf10eb0Be035;
    address internal RegistrarControllerAddress = 0x283Af0B28c62C092C9727F1Ee09c02CA627EB7F5;
    uint256 internal renewalPeriod = 28 days;

    BaseRegistrar ensReg;
    ENS ens;
    ENSRegistrarController ensRegController;
    BulkRenewal ensBulkRenewal;
    ENSResolver ensResolver;

    /// @dev map user address to arrays of their names and expiry times
    //mapping (address => uint256[]) names;

    /// @dev map names to the users that are funding them
    //mapping (uint256 => address[]) users;

    uint256[] nameList;

    constructor(uint256 _networkID) {
        if (_networkID == 1 || _networkID == 3){
            ensReg = BaseRegistrar(baseRegistrarAddress);
            ens = ENS(ensReg.ens());
            ensBulkRenewal = BulkRenewal(bulkRenewalAddress);
            ensRegController = ENSRegistrarController(RegistrarControllerAddress);
        }
    }

    receive() external payable {}

    function executeBulkRenewal(string[] memory _names, uint256 _duration) external {
        if(_duration == 0){ _duration = renewalPeriod;}
        bytes4 _interfaceID = 0x3150bfba;
        require(ensBulkRenewal.supportsInterface(_interfaceID),"Incorrect ENS BulkRenewal address");
        ensBulkRenewal.renewAll{value:address(this).balance}(_names, _duration);
        msg.sender.transfer(address(this).balance);
    }

    function checkBulkPrice(string[] memory _names, uint256 _duration) public view returns(uint256) {
        return ensBulkRenewal.rentPrice(_names, _duration);
    }

    function checkPrice(string memory _name, uint256 _duration) public view returns(uint256) {
        return ensRegController.rentPrice(_name, _duration);
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

    /// @notice pass in an array of names and return the ones that are due for renewal and the total cost.
    function checkForRenewals(uint256[] memory _nameList) public view returns(uint256[] memory, uint256){
        uint256 _count = countRenewals(_nameList);
        uint256 _price;
        uint256[] memory _names = new uint256[](_count);
        uint256 _j;
        for (uint i; i < _nameList.length; i++) {
            if(renewalDue(_nameList[i])) {
                _names[_j] = _nameList[i];
                _j++;
            }
        }
        string[] memory _strNames = new string[](_count);
        _strNames = uintArrayToStringsArray(_names);
        if(_count == 1){
            _price = checkPrice(_strNames[0], renewalPeriod);
        } else {
            _price = checkBulkPrice(_strNames, renewalPeriod); 
        }
        return (_names, _price);
    }

    function countRenewals(uint256[] memory _nameList) public view returns (uint256){
        uint256 _count;
        for (uint i; i < _nameList.length; i++) {
            if(renewalDue(_nameList[i])) {
                _count++;
            }
        }
        return (_count);
    }

 
    /*
    *
    *   ENS Related Functions
    *
    */

    function returnHash(string[] calldata _name) public pure returns(bytes32){
        bytes32 _nameHash;
        _nameHash = computeHash(_name[0], _nameHash);
        for (uint256 i = 1; i < _name.length; i++){
            _nameHash = computeHash(_name[i], _nameHash); 
        }
        return _nameHash;
    }

    /// @notice pass in either the _name or _nameHash to resolve an address
    function resolveName(string[] calldata _name) public view returns(address){
        bytes32 _nameHash = returnHash(_name);
        ENSResolver _ensResolver =  ENSResolver(ens.resolver(_nameHash));
        return(_ensResolver.addr(_nameHash));
    }

    function renewalDue(uint256 _labelhash) public view returns(bool) {
        return (getNameExpiry(_labelhash) <= block.timestamp + renewalPeriod);
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
    function computeHash(string calldata _subdomain, bytes32 _name) public pure returns (bytes32 namehash) {
        namehash = keccak256(abi.encodePacked(_name, keccak256(abi.encodePacked(_subdomain))));
    }

    // for testing purposes
    function retrieveETH() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function updateAddresses(address _ens) public {
            ens = ENS(_ens);
            ensReg = BaseRegistrar(ens.baseRegAddress());
            ensBulkRenewal = BulkRenewal(ens.bulkRegAddress());
            ensRegController = ENSRegistrarController(ens.regContAddress());
    }
}
