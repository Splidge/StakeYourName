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
    function balance(address _asset) external view returns(uint256);
    function setBalance(address _asset, uint256 _balance) external  returns(uint256);
}