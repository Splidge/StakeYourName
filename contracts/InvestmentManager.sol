// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "interfaces/ILendingPool.sol";
import "interfaces/IProtocolDataProvider.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/drafts/ERC20Permit.sol"; 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/SafeCast.sol";

  /**
   * @title Manages depositing and withdrawing from Aave
   * @notice part of the StakeYourName DApp
   * @author Daniel Chilvers
   **/
contract InvestmentManager is Ownable {

    using SafeMath for uint256;

    //address internal kovanLendingPool = 0x9FE532197ad76c5a68961439604C037EB79681F0;
    //address internal mainLendingPool = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
    address internal deadAddress = 0x000000000000000000000000000000000000dEaD;
    address internal lendingPooladdress = deadAddress;
    address internal kovanLendingPoolAddressProviderAddress = 0x88757f2f99175387aB4C6a4b3067c77A695b0349;
    address internal mainLendingPoolAddressProviderAddress = 0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5;
    address internal lendingPoolAddressProviderAddress = deadAddress;
    address internal ProtocolDataProviderAddress = deadAddress;

    /// @dev addresses saved here for testing, in final version the
    /// @dev addresses will be passed in from the front end.
    address internal DAIContract = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal USDCContract = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    uint16 referralCode = 0;
    uint256 constant MAX_INT = 2**256 - 1;

    /// @dev TO:DO change to saving the asset symbol instead 
    /// @dev then this will be packed and we save gas
    /// @dev TO:DO change arrays to mappings to remove for loops 
    struct User {
        mapping (address => uint128) balance;
        mapping (address => uint128) allowance;
        mapping (address => bool) locked;
    }

    /// @dev map user addresses to our struct above
    mapping (address => User) Users;

    IProtocolDataProvider.TokenData[] public aTokens;

    ILendingPool lendingPool;
    ILendingPoolAddressesProvider lendingPoolAddressesProvider;
    IProtocolDataProvider protocolDataProvider;
    IERC20 ierc20;

    constructor(uint _networkID) {
        /// @dev truffle will pass in the networkID when migrated, use this to select the correct address
        if (_networkID == 1){
            lendingPoolAddressProviderAddress = mainLendingPoolAddressProviderAddress;
        } else if (_networkID == 42){
            lendingPoolAddressProviderAddress = kovanLendingPoolAddressProviderAddress;
        } 
        lendingPoolAddressesProvider = ILendingPoolAddressesProvider(lendingPoolAddressProviderAddress);
        lendingPooladdress =  lendingPoolAddressesProvider.getLendingPool();
        protocolDataProvider = IProtocolDataProvider(lendingPoolAddressesProvider.getAddress(bytes32('0x1')));
        lendingPool = ILendingPool(lendingPooladdress);
    }

    event debug(address _address, uint256 state);

    function approveLendingPool(address _asset) public {
        ierc20 = IERC20(_asset);
        ierc20.approve(lendingPooladdress , MAX_INT);
    }

    /// @notice just does a deposit, don't record to a users balance
    /// @dev just for testing, remove later
    function depositTest(address _asset, uint256 _amount) public {
        ierc20 = IERC20(_asset);
        ierc20.transferFrom(msg.sender, address(this), _amount);
        lendingPool.deposit(_asset, _amount, address(this) , referralCode);
    }

    /// @notice just does a withdrawl, doesn't record to a users balance
    /// @dev just for testing, remove later
    function withdrawTest(address _asset, uint256 _amount) public {
        lendingPool.withdraw(_asset, _amount, msg.sender);
    }

    /// @notice approves an _asset transfer for an _amount and records it
    function approveDeposit(address _asset, uint128 _amount) public returns(bool) {
        ierc20 = IERC20(_asset);
        ierc20.approve(address(this), _amount);
        Users[msg.sender].allowance[msg.sender] =  _amount;
    }


    function checkAllowance (address _asset) public view returns(uint128){
        return Users[msg.sender].allowance[_asset];
    }

    /// @dev can we make the deposit a require? to save gas.
    function deposit(address _asset, uint128 _amount) public {
        require(checkAllowance(_asset) >= Users[msg.sender].balance[_asset], "User not approved to send this amount");
        lendingPool.deposit(_asset, _amount, address(this) , referralCode);
        Users[msg.sender].balance[_asset] = safeAddUint128(Users[msg.sender].balance[_asset], _amount );
    }

    /// @notice allow the lendingPool to burn _amount of aTokens in order to withdraw _asset
    function approveATokenBurn(uint128 _amount, address _asset) public {
        ierc20 = IERC20(_asset);
        ierc20.approve(lendingPooladdress , _amount);
    }

    ///@dev this needs updating so users can withdraw interest also
    function withdraw(address _asset, uint128 _amount) public {
        require(Users[msg.sender].balance[_asset] >= _amount, "Attempting to withdraw too much");
        lendingPool.withdraw(_asset, _amount, msg.sender);
        Users[msg.sender].balance[_asset] = safeSubUint128(Users[msg.sender].balance[_asset], _amount);
    }

    /// @notice uses the SafeMath and SafeCast libraries to safely add uint128s together
    function safeAddUint128(uint128 _a, uint128 _b) internal pure returns(uint128){
        return(SafeCast.toUint128(uint256(_a).add(uint256(_b))));
    }
    /// @notice uses the SafeMath and SafeCast libraries to safely subtract uint128s 
    function safeSubUint128(uint128 _a, uint128 _b) internal pure returns(uint128){
        return(SafeCast.toUint128(uint256(_a).sub(uint256(_b))));
    }

    /// @notice don't send me funds if this function still exists
    /// @dev for recovering test funds
    function withdrawAll() public onlyOwner {
        require(msg.sender.send(address(this).balance));
    }

    function updateReferalCode(uint16 _code) public onlyOwner {
        referralCode = _code;
    }

    /// @notice verify the address of the lending pool in use
    function checkLendingPoolAddress() public view returns(address){
        return (lendingPooladdress);
    }

    /// @notice verify the address of the lending pool address provider
    /// @dev maybe try and shorten the function name a bit
    function checkLendingPoolAddressProviderAddress() public view returns(address){
        return (lendingPoolAddressProviderAddress);
    }

    /// @notice update the lending pool address from the address provider
    function updateLendingPoolAddress() public onlyOwner returns(address){
        lendingPooladdress = lendingPoolAddressesProvider.getLendingPool();
        lendingPool = ILendingPool(lendingPooladdress);
        emit debug(lendingPooladdress, 10);
        return (lendingPooladdress);
    }

}