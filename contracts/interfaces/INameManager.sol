// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

/// @title StakeYourName - NameManager
/// @notice Maintains a list of users and names they want to keep renewed
/// @notice Can check for name expiry and pay for renewals
/// @author Daniel Chilvers

interface INameManager {
    receive() external payable;
    function returnHash(string [] calldata _name) external pure returns(bytes32);
    function executeBulkRenewal(string[] memory _names, uint256 _duration) external payable;
    function checkBulkPrice(string[] memory _names, uint256 _duration) external view returns(uint256);
    function checkPrice(string memory _name, uint256 _duration) external view returns(uint256);
    function uintArrayToStringsArray(uint256[] memory _ints) external pure returns(string[] memory);
    function checkForRenewals(uint256[] memory _nameList) external view returns(uint256[] memory, uint256);
    function countRenewals(uint256[] memory _nameList) external view returns (uint256);
    function resolveName(string[] calldata _name) external view returns(address);
    function renewalDue(uint256 _labelhash) external view returns(bool);
    function updateRenewalPeriod(uint256 _time) external;
    function updateRegistrar(address _address) external;
    function updateBulkRenewal(address _address) external;
    function getNameExpiry(uint256 _name) external view returns(uint256);
    function returnEnsAddress() external view returns(address);
    function returnEnsRegAddress() external view returns(address);
    function returnBulkRenewalAddress() external view returns(address);
    function checkRegistryMatches() external view returns(bool);
    function convertBytesToUint(bytes32 _bytes) external pure returns(uint256);
    function convertUintToBytes(uint256 _uint) external pure returns(bytes32);
    function computeHash(string calldata _subdomain, bytes32 _name) external pure returns (bytes32 namehash) ;
    function retrieveETH() external;
    function updateAddresses(address _ens) external;
}
