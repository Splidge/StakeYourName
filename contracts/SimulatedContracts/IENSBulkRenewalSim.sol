// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

interface IBulkRenewalSim {

    // Simulated functions
    function ens() external view returns(address);
    function renewAll(string[] calldata _id, uint256 _duration) external payable ;
    function supportsInterface(bytes4) external pure returns(bool);


    // admin functions
    function withdraw() external ;
    function updateENS(address _ensAddress) external ;
    function updateBaseRegistrar(address _ensBaseRegAddress) external ;
}