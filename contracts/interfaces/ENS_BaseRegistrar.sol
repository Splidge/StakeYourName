// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

// Created by Daniel Chilvers
interface BaseRegistrar {

    // View functions
    
    function GRACE_PERIOD() external view returns (uint256); // Grace period before a name expires currently 90 days
    function available(uint256 id) external view returns(bool); // Returns true iff the specified name is available for registration.
    function balanceOf(address owner) external view returns (uint256 balance); // Gets the balance of the specified address, how many names?
    function baseNode() external view returns (bytes32); //The namehash of the TLD this registrar owns (eg, .eth)
    function controllers(address) external view returns(bool); // A map of addresses that are authorised to register and renew names.
    function ens() external view returns (address); // ENS Registry address
    function getApproved(uint256 tokenId) external view returns (address); //Gets the approved address for a token ID, or zero if no address set
    function isApprovedForAll(address owner, address operator) external view returns (bool); //Tells whether an operator is approved by a given owner
    function isOwner() external view returns (bool); // Am i the owner?
    function nameExpires(uint256 id) external view returns(uint); // Returns the expiration timestamp of the specified label hash.
    function owner() external view returns (address); // Who is the owner of the contract?
    function ownerOf(uint256 tokenId) external view returns (address); //Gets the owner of the specified token ID
    function supportsInterface(bytes4 interfaceID) external view returns (bool); // who's supporting who here?


    // You can't just View these functions.

    function addController(address controller) external; // Authorises a controller, who can register and renew domains.
    function approve(address to, uint256 tokenId) external; // Approves another address to transfer the given token ID
    function removeController(address controller) external; // Revoke controller permission for an address.
    function reclaim(uint256 id, address owner) external; //Reclaim ownership of a name in ENS, if you own it in the registrar.
    function register(uint256 id, address owner, uint duration) external returns(uint); //Register a name.
    function registerOnly(uint256 id, address owner, uint duration) external returns(uint); //Register a name, without modifying the registry.
    function renew(string memory name, uint duration) external payable; // renew a name that is already owner or within the grace period
    function renounceOwnership() external; //onlyOwner renounces ownership of contract
    function safeTransferFrom(address from, address to, uint256 tokenId) external; //Safely transfers the ownership of a given token ID to another address
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) external;
    function setApprovalForAll(address to, bool approved) external; // Sets or unsets the approval of a given operator
    function setResolver(address resolver) external; // Set the resolver for the TLD this registrar manages.
    function transferFrom(address from, address to, uint256 tokenId) external; // transfer ownership of a token, use safetransfer instead
    function transferOwnership(address newOwner) external; //onlyOwner transfers contract to new owner
}