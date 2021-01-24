// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface NameManager {
    function checkForRenewals() external view returns(uint256[] memory);
    function addRecord(uint256 _name) external;
    function removeRecord(uint256 _name) external;
    function checkForName(uint256 _name) external view returns(bool, uint256);
    function countFunders(uint256 _name) external view returns(uint256);
    function checkForUser(uint256 _name) external view returns(bool, uint256);
    
    function resolveName(string calldata _name, bytes32 _nameHash) external returns(address);
    function updateBulkRenewal(address _address) external; //only owner
    function updateRegistrar(address _address) external; //only owner
    function getNameExpiry(uint256 _name) external view returns(uint256);
    function renewalDue(uint256 _labelhash) external view returns(bool);
    function updateRenewalPeriod(uint256 _time) external; //only owner
    
    // ENS helper functions, these may be internal in final version
    function convertBytesToUint(bytes32 _bytes) external pure returns(uint256);
    function convertUintToBytes(uint256 _uint) external pure returns(bytes32);
    function computeNamehash(string calldata _name) external pure returns (bytes32 namehash);
    function computeLabelhash(string calldata _name) external pure returns (bytes32 namehash);
    
    // Check all the address'
    function returnEnsAddress() external view returns(address);
    function returnEnsRegAddress() external view returns(address);
    function returnBulkRenewalAddress() external view returns(address);
    function checkRegistryMatches() external view returns(bool);
    
    //test functions
    function addTestRecord (uint256 _index, uint256 _int) external;
    function deleteTestRecord (uint256 _index, uint256 _int) external;
    function countTestRecord (uint256 _index) external returns(uint256);
    function countTestRecordView (uint256 _index) external view returns(uint256);
}