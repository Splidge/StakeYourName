// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "interfaces/ILendingPool.sol";
import "interfaces/IProtocolDataProvider.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

  /**
   * @title Manages depositing and withdrawing from Aave
   * @notice part of the StakeYourName DApp
   * @author Daniel Chilvers
   **/
contract InvestmentManager is Ownable {
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

    /// @dev TO;DO change to saving the asset symbol instead 
    /// @dev then this will be packed and we save gas
    struct User {
        address asset;
        uint128 balance;
        bool locked;
    }

    /// @dev map user addresses to our struct above
    mapping (address => User[]) Users;

    IProtocolDataProvider.TokenData[] public aTokens;

    ILendingPool lendingPool;
    ILendingPoolAddressesProvider lendingPoolAddressesProvider;
    IProtocolDataProvider protocolDataProvider;

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
    }

    event debug(address _address);


    function deposit(address _reserve, uint128 _amount) public payable{
        uint _index = 0;
        /// @dev check if the user already has some of this asset   
        for (uint i; i <= Users[msg.sender].length ; i++) {
            if (Users[msg.sender][i].asset == _reserve ){
                _index = i;
            } else {
                Users[msg.sender].push();
            }
            lendingPool.deposit(_reserve, _amount, address(this) , referralCode);
            Users[msg.sender][_index].balance = Users[msg.sender][_index].balance + _amount;
        }
    }

    function withdraw(address _reserve, uint128 _amount) public {
        uint _index = 0;
        bool _owned = false;
        for (uint i; i <= Users[msg.sender].length ; i++) {
            if (Users[msg.sender][i].asset == _reserve ){
                _index = i;
                _owned = true;
            }
        }
        if (_owned = true || Users[msg.sender][_index].balance >= _amount){
            lendingPool.withdraw(_reserve, _amount, msg.sender);
        }
        
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
        emit debug(lendingPooladdress);
        return (lendingPooladdress);
    }

}