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
    address internal zeroAddress = address(0);
    address internal lendingPooladdress = zeroAddress;
    address internal kovanLendingPoolAddressProviderAddress = 0x88757f2f99175387aB4C6a4b3067c77A695b0349;
    address internal mainLendingPoolAddressProviderAddress = 0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5;
    address internal lendingPoolAddressProviderAddress = zeroAddress;
    address internal ProtocolDataProviderAddress = zeroAddress;

    uint16 referralCode = 0;
    uint256 constant MAX_INT = type(uint256).max;
    uint256 internal MIN_APPROVAL = type(uint256).max/2;

    IProtocolDataProvider.TokenData[] public aTokens;

    ILendingPool lendingPool;
    ILendingPoolAddressesProvider lendingPoolAddressesProvider;
    IProtocolDataProvider protocolDataProvider;
    IERC20 ierc20;

    constructor(uint _networkID) {
        /// @dev truffle will pass in the networkID when migrated, use this to select the correct addresses
        /// @dev uprgading to ^0.8.0 we could use block.chainid instead
        if (_networkID == 1){
            lendingPoolAddressProviderAddress = mainLendingPoolAddressProviderAddress;
            protocolDataProvider = IProtocolDataProvider(0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d);
        } else if (_networkID == 42){
            lendingPoolAddressProviderAddress = kovanLendingPoolAddressProviderAddress;
            protocolDataProvider = IProtocolDataProvider(0x3c73A5E5785cAC854D468F727c606C07488a29D6);
        } 
        lendingPoolAddressesProvider = ILendingPoolAddressesProvider(lendingPoolAddressProviderAddress);
        lendingPooladdress =  lendingPoolAddressesProvider.getLendingPool();
        //protocolDataProvider = IProtocolDataProvider(lendingPoolAddressesProvider.getAddress(bytes32('0x1')));
        lendingPool = ILendingPool(lendingPooladdress);
    }

    event debug(address _address, uint256 state);

    /// @notice Approves sending _asset ERC20 tokens to the lendingPool
    /// @param _asset the address of asset contract
    /// @param _userVault the address of the user vault
    /// @dev this needs to be called for each new asset purchased
    function approveLendingPool(address _asset, address _userVault) external {
        IERC20 _erc20 = IERC20(_asset);
        if (_erc20.allowance(_userVault, lendingPooladdress) <= MIN_APPROVAL){
            _erc20.approve(lendingPooladdress, MAX_INT);
        } 
    }

    function getAToken(address _asset) public view returns(address){
        address _aTokenAddress;
        (_aTokenAddress,,) = protocolDataProvider.getReserveTokensAddresses(_asset);
        return _aTokenAddress;
    }

    function getATokenBalance(address _asset, address _userVault) external view returns(uint256){
        IERC20 _erc20 = IERC20(getAToken(_asset));
        return _erc20.balanceOf(_userVault);
    }

    /// @dev User must have approved this contract before this is called
    function deposit(address _asset, address _userVault, uint256 _amount) external {
        lendingPool.deposit(_asset, _amount, _userVault, referralCode);
    }

    function checkAllowance(address _asset) external view returns(uint256){
        IERC20 _erc20 = IERC20(_asset);
        return _erc20.allowance(msg.sender, address(lendingPool));
    }

    ///@dev put these transfers into require statements
    function withdraw(address _asset, uint256 _amount, address _user) external {
        lendingPool.withdraw(_asset, _amount, _user);
    }
}