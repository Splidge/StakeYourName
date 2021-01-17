// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "interfaces/ENS_Registry.sol";
import "interfaces/ENS_BaseRegistrar.sol";
import "interfaces/ENS_BulkRenewal.sol";


// @title Renew names on the ENS when required
// @author Daniel Chilvers

contract NameManager is Ownable {
    // @dev can probably remove ensRegistryAddress as it can be discovered from the Registrar
    address internal ensRegistryAddress = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;
    address internal baseRegistrarAddress = 0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85;
    address internal bulkRenewalAddress = 0xfF252725f6122A92551A5FA9a6b6bf10eb0Be035;
    uint256 internal renewalPeriod = 28 days; 

    BaseRegistrar ensReg;
    ENS ens;
    BulkRenewal ensBulkRenewal;

    constructor() {
        ensReg = BaseRegistrar(baseRegistrarAddress);
        //ens = ENS(ensReg.ens());
        ensBulkRenewal = BulkRenewal(bulkRenewalAddress);
        
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
    // @devs always fails on testnet because they didn't impletment bulk renewal there
    function checkRegistryMatches() public view returns(bool){
        return (ensReg.ens() == ensBulkRenewal.ens());
    }

    // @notice funtions to help out with ENS integration
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
