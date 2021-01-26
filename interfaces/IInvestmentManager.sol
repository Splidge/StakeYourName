// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface InvestmentManager {

    function approveLendingPool(address _asset) external ;
    function userBalance(address _asset) external view returns(uint128);

    function userInterest(address _asset) external view returns(uint128);

    function getAToken(address _asset) external view returns(address);

    function getATokenBalance(address _asset) external returns(uint256);
    function calculateInterest(address _asset) external ;

    function depositTest(address _asset, uint256 _amount) external ;
    function withdrawTest(address _asset, uint256 _amount) external;

    function approveDeposit(address _asset, uint128 _amount) external ;

    function checkAssetList(address _asset) external view returns(bool);

    /// @notice adds an _asset to the assetList and approves sending to the lendingPool
    function addAsset(address _asset) external ;

    /// @notice checks if this user has purchased this asset previously
    function checkUserList(address _asset) external view returns(bool);

    /// @notice records that the user has now purchased _asset
    function addUser(address _asset) external ;

    function checkAllowance (address _asset) external returns(uint256);

    /// @dev TO:DO add some more requires to potentially save gas
    function deposit(address _asset, uint128 _amount) external ;

    /// @dev don't think we need to do this!?
    function approveATokenBurn(address _asset, uint256 _amount) external ;

    ///@dev current implemnetation withdraws balance before deposit.
    function withdraw(address _asset, uint128 _amount) external ;

    function convertInterestToBalance(address _asset, uint128 _amount) external ;

    /// @dev only call this after calculateInterest()
    function userTotal(address _asset) external view returns(uint128) ;


    /// @notice don't send me funds if this function still exists
    /// @dev for recovering test funds
    function withdrawAll() external  ;

    function updateReferalCode(uint16 _code) external ;

    /// @notice verify the address of the lending pool in use
    function checkLendingPoolAddress() external view returns(address);

    /// @notice verify the address of the lending pool address provider
    /// @dev maybe try and shorten the function name a bit
    function checkLendingPoolAddressProviderAddress() external view returns(address);
    
    function checkProtocolDataProvider() external view returns(address);

    function updateProtocolDataProvider(bytes1 _bytes) external returns(address, bytes32);

    function checkaTokenAddress(address _asset) external view returns(address);

    /// @notice update the lending pool address from the address provider
    function updateLendingPoolAddress() external returns(address);

}
