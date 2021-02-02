// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

/// @title StakeYourName - Main Contract
/// @notice Handles interations between the users and
/// @notice other StakeYourName contracts.
/// @author Daniel Chilvers

interface IStakeYourName {

    /******************************************** 
    *                                           *
    *   User functions                          *
    *                                           *
    ********************************************/

    function addName(string[] calldata _name) external;
    function addMultipleNames(string[][] calldata _names) external;
    function removeName(uint256 _name) external;
    function removeMultipleNames(uint256[] calldata _names) external;
    function deposit(address _asset, uint256 _amount) external;
    function withdraw(address _asset, uint256 _amount) external;
    /******************************************** 
    *                                           *
    *   User Vault deployment and functions.    *
    *                                           *
    ********************************************/

    function deployVault() external;
    function setMasterVault(address _vault) external;
    function setBalance(address _asset, uint256 _balance) external;
    function findVault(address _vault) external view returns(address);
    function approveVault(address _asset) external;
    function vaultAddAsset(address _asset) external;
    function vaultRemoveAsset(address _asset) external;
    function getOwner() external view returns(address);
    /******************************************** 
    *                                           *
    *   Name functions                          *
    *                                           *
    ********************************************/

    function renewNames(address _user) external;
    function renewNamesGroupingUsers() external view;
    function countRenewals(address[] memory _users) external view returns(uint256 _count);
    function swapAssets() external view;
    /******************************************** 
    *                                           *
    *   Admin functions                         *
    *                                           *
    ********************************************/

    receive() external payable;
    function updateReferral(uint256 _ref) external;
    /******************************************** 
    *                                           *
    *   Test and/or temporary functions.        *
    *                                           *
    ********************************************/

    function setNameManager(address _address) external;
    function setExchangeManager(address _address) external;
    function setInvestmentManager(address _address) external;
    function approveInvestmentManager(address _asset) external;
    function setupTestNet(
        address payable _nameManager,
        address payable _exchangeManager,
        address _investmentManager,
        address _vault,
        address _oneSplit,
        address _ens
    ) external;
    function retrieveETH() external;
    function emptyVault(address _vault) external;
}