// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

  /**
   * @title UserVault - Interface
   * @notice a personal asset vault for each user
   * @notice part of the StakeYourName DApp
   * @author Daniel Chilvers
   **/

interface UserVault{
    function initialize() external;
    function owner() external view returns(address);
    function names() external view returns(uint256[] memory);
    function assets() external view returns(address[] memory);
    function balance(address _asset) external view returns(uint256);
    function setBalance(address _asset, uint256 _balance) external returns(uint256);
    function approve(address _asset) external;
    function addName(uint256 _name) external;
    function addMultipleNames(uint256[] calldata _names) external;
    function removeName(uint256 _name) external;
    function removeMultipleNames(uint256[] calldata _names) external;
    function addAsset(address _asset) external;
    function removeAsset(address _asset) external;
}