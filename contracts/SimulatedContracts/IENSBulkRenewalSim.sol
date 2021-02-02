// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

interface IENSBulkRenewalSim {

    // Simulated functions
    function ens() external view returns(address);
    function renewAll(string[] calldata _id, uint256 _duration) external payable;
    function supportsInterface(bytes4) external pure returns(bool);
    // admin functions
    function withdraw() external;
    function updateENS(address _ensAddress) external;
    function updateRegCont(address _regCont) external;
}