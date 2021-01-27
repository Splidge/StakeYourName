// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface ENSRegistrarController {

    function minCommitmentAge() external pure returns(uint256);
    function maxCommitmentAge() external pure returns(uint256);
    function commitments(bytes32) external pure returns(uint256);
    function MIN_REGISTRATION_DURATION() external pure returns(uint256);
    function rentPrice(string memory name, uint duration) view external returns(uint);
    function valid(string memory name) external pure returns(bool);
    function available(string memory name) external view returns(bool);
    function makeCommitment(string memory name, address owner, bytes32 secret) pure external returns(bytes32);
    function makeCommitmentWithConfig(string memory name, address owner, bytes32 secret, address resolver, address addr) pure external returns(bytes32);
    function commit(bytes32 commitment) external;
    function register(string calldata name, address owner, uint duration, bytes32 secret) external payable;
    function registerWithConfig(string memory name, address owner, uint duration, bytes32 secret, address resolver, address addr) external payable;
    function renew(string calldata name, uint duration) external payable;
    function supportsInterface(bytes4 interfaceID) external pure returns (bool);
}