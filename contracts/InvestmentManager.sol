// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

//@title Manages investments on Aave
//@creator Daniel Chilvers

contract InvestmentManager {
    address internal kovanLendingPool = 0x9FE532197ad76c5a68961439604C037EB79681F0;
    address internal mainLendingPool = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
    address internal lendingPooladdress = 0x000000000000000000000000000000000000dEaD;

    //@dev truffle will pass in the networkID when migrated, use this to select the correct address
    constructor(uint _networkID) {
        if (_networkID == 1){
            lendingPooladdress = mainLendingPool;
        } else if (_networkID == 42){
            lendingPooladdress = kovanLendingPool;
        } 
        
    }

    function checkLendingPoolAddress() public view returns(address){
        return (lendingPooladdress);
    }

}