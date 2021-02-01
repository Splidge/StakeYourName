// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

// Created by Daniel Chilvers
interface BulkRenewal {
    // @notice have a VIEW of these PURE functions
    function rentPrice(string[] calldata names, uint duration) external view returns(uint total); //get the prices
    function BULK_RENEWAL_ID() external view returns (bytes4); // the ID required if the contract supports bulk renewals
    function supportsInterface(bytes4 interfaceID) external pure returns (bool); // check it supports the interface we need
    function ens() external view returns (address); // ENS Registry address

    // @notice you better pay up to use this, pay a bit extra to be safe as you'll get change back
    function renewAll(string[] calldata names, uint duration) external payable; // renew them all
}