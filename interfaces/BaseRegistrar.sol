// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

interface BaseRegistrar {
    function GRACE_PERIOD() external view returns (uint256);
    function available(uint256 id) external view returns(bool);
    function balanceOf(address owner) external view returns (uint256 balance);
    function baseNode() external view returns (bytes32);
    function controllers(address) external view returns(bool);
    function ens() external view returns (address);
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function isOwner() external view returns (bool);
    function nameExpires(uint256 id) external view returns(uint);
    function owner() external view returns (address);
    function ownerOf(uint256 tokenId) external view returns (address);
    function supportsInterface(bytes4 interfaceID) external view returns (bool);

    function renew(string memory name, uint duration) external payable;

}