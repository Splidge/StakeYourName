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

    /// @dev TO;DO change to saving the asset symbol instead 
    /// @dev then this will be packed and we save gas
    struct User {
        address[] asset;
        uint128[] balance;
        uint128[] allowance;
        bool locked;
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
    function depositTest(address _reserve, uint256 _amount) public {
        ierc20 = IERC20(_reserve);
        ierc20.transferFrom(msg.sender, address(this), _amount);
        lendingPool.deposit(_reserve, _amount, address(this) , referralCode);
    }

    /// @notice just does a withdrawl, doesn't record to a users balance
    function withdrawTest(address _reserve, uint256 _amount) public {
        lendingPool.withdraw(_reserve, _amount, msg.sender);
    }

    /// @notice approves an _asset transfer for an _amount and records it
    function approveDeposit(uint128 _amount, address _asset) public returns(bool) {
        uint256 _index = MAX_INT;
        bool _success;
        ierc20 = IERC20(_asset);
        /// @dev check if the user already has some of this asset
        for (uint i; i <= Users[msg.sender].asset.length ; i++) {
            if (Users[msg.sender].asset[i] == _asset ){
                _index = i;
                break;
            } 
        }
        if (_index == MAX_INT) {      
            /// @dev they don't own any yet, lets add a record
            Users[msg.sender].asset.push();
            Users[msg.sender].balance.push();
            Users[msg.sender].allowance.push();
            _index = 0; 
        } 
        /// @dev now lets approve for the amount
        /// @dev it'd be prefered to increase or decrease approval but
        /// @dev we can't guarentee contract compatibility
        _success = ierc20.approve(address(this), _amount);
        Users[msg.sender].asset[_index] = _asset;
        Users[msg.sender].allowance[_index] =  _amount;
    }

    function checkApproval (address _asset) public view returns(uint128){
        for (uint i; i <= Users[msg.sender].asset.length ; i++) {
            if (Users[msg.sender].asset[i] == _asset ){
                return Users[msg.sender].allowance[i];
            } 
        }
    return 0;
    }


    function deposit(address _reserve, uint128 _amount) public {
        //require(checkApproval(_reserve) >=  )
        uint256 _index = MAX_INT;
        for (uint i; i <= Users[msg.sender].asset.length ; i++) {
            if (Users[msg.sender].asset[i] == _reserve ){
                _index = i;
                break;
            }
        }

        lendingPool.deposit(_reserve, _amount, address(this) , referralCode);
        Users[msg.sender].balance[_index] = safeAddUint128(Users[msg.sender].balance[_index], _amount );
        
    }

    function approveWithdraw(uint128 _amount, address _asset) public returns(bool) {
        uint256 _index = 0;
        bool _success;
        address aToken;
        (aToken,,) = protocolDataProvider.getReserveTokensAddresses(_asset);
        ierc20 = IERC20(aToken);

        /// @dev check if the user has some of this asset to withdraw
        for (uint i; i <= Users[msg.sender].asset.length ; i++) {
            if (Users[msg.sender].asset[i] == _asset ){
                _index = i;
            }else {
                /// @dev they don't own any
                //Users[msg.sender].asset.push();
                //Users[msg.sender].balance.push();
                //Users[msg.sender].allowance.push();
                emit debug(msg.sender, 4);
                _success = false;
                return (_success);
            }
        }
        Users[msg.sender].asset[_index] = _asset;
        Users[msg.sender].allowance[_index] = safeSubUint128(Users[msg.sender].allowance[_index], _amount );
        _success = ierc20.approve(msg.sender, _amount);
        emit debug(msg.sender, 5);
        return(_success);
    }

    function withdraw(address _reserve, uint128 _amount) public {
        uint _index = 0;
        bool _owned = false;
        for (uint i; i <= Users[msg.sender].asset.length ; i++) {
            if (Users[msg.sender].asset[i] == _reserve ){
                _index = i;
                _owned = true;
            }
        }
        if (_owned = true && Users[msg.sender].balance[_index] >= _amount){
            lendingPool.withdraw(_reserve, _amount, msg.sender);
        } else {
            emit debug(msg.sender, 6);
        }
        
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