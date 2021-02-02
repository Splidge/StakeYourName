// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IENSRegControllerSim {
    // Simulated functions
    function ens() external view returns(address);
    function renew(string calldata _id, uint256 _duration) external payable;
    function rentPrice(string memory _name, uint256 _duration) external view returns(uint256);
    // admin functions
    function expires(uint256 _id) external view returns(uint256);
    function withdraw() external;
    function updateENS(address _ensAddress) external;
    function updateName(uint256 _name, uint256 _expiry) external;
    function day() external;
    function month() external;
    function convertBytesToUint(bytes32 _bytes) external pure returns(uint256);
    function convertUintToBytes(uint256 _uint) external pure returns(bytes32);
    function computeHash(string memory _subdomain, bytes32 _name) external pure returns (bytes32 namehash);
    function retrieveETH() external;
}