// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "interfaces/ILendingPool.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

  /**
   * @title Manages depositing and withdrawing from Aave
   * @notice part of the StakeYourName DApp
   * @author Daniel Chilvers
   **/
contract InvestmentManager is Ownable {
    //address internal kovanLendingPool = 0x9FE532197ad76c5a68961439604C037EB79681F0;
    //address internal mainLendingPool = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
    address internal lendingPooladdress = 0x000000000000000000000000000000000000dEaD;
    address internal kovanLendingPoolAddressProviderAddress = 0x652B2937Efd0B5beA1c8d54293FC1289672AFC6b;
    address internal mainLendingPoolAddressProviderAddress = 0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5;
    address internal lendingPoolAddressProviderAddress = 0x000000000000000000000000000000000000dEaD;
    uint16 referralCode = 0;

    ILendingPool LendingPool;
    ILendingPoolAddressesProvider lendingPoolAddressesProvider;

    constructor(uint _networkID) {
        /// @dev truffle will pass in the networkID when migrated, use this to select the correct address
        if (_networkID == 1){
            lendingPoolAddressProviderAddress = mainLendingPoolAddressProviderAddress;
        } else if (_networkID == 42){
            lendingPoolAddressProviderAddress = kovanLendingPoolAddressProviderAddress;
        } 
        lendingPoolAddressesProvider = ILendingPoolAddressesProvider(lendingPoolAddressProviderAddress);
        lendingPooladdress =  lendingPoolAddressesProvider.getLendingPool();
    }


    function deposit(address reserve, address user, uint256 _amount) internal {
        LendingPool.deposit(reserve, _amount, address(this) , referralCode);
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
        return (lendingPooladdress);
    }

}