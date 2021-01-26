// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "interfaces/INameManager.sol";
import "interfaces/IInvestmentManager.sol";
import "interfaces/IExchangeManager.sol";
import "interfaces/ENS_BulkRenewal.sol";
import "interfaces/ENS_Resolver.sol";

/// @title StakeYourName - Main Contract
/// @notice Handles interations between the users and
/// @notice other StakeYourName contracts.
/// @author Daniel Chilvers

contract StakeYourName is Ownable {

    /// @notice User data, maps a user address to their asset addresses balance, interest earnt
    /// @notice and also the list of names they're funding
    /// @dev we can increase balance to uint256, changing to mappings removed the packing benefits
    struct User {
        mapping (address => uint128) balance;
        mapping (address => uint128) interest;
        uint256[] names;
    }

    /// @dev map user addresses to our struct above
    mapping (address => User) Users;

    /// @dev balance, how many of each token bought
    /// @dev interest, how much interest earnt so far
    /// @dev interestCalcualtionTime, block.timestamp of last calculation
    /// @dev TO:DO pack this struct better
    /// @dev lets try not to use this
    /*struct Asset {
        uint256 balance;
        uint256 interest;
        //uint256 interestCalculationTime;
        address[] userList;
    }

    mapping (address => Asset) assets;
    */

    /// @dev save a list of any assests we've puchased
    address[] public assetList;
    /// @dev save a list of users 
    address[] public userList;

    /// @dev map user address to arrays of their names
    /// @dev moved into user struct, use 
    // mapping (address => uint256[]) names;

    /// @dev map names to the users that are funding them
    //mapping (uint256 => address[]) users;

    //uint256[] nameList;

    NameManager nameManager;
    ExchangeManager exchangeManager;
    InvestmentManager investmentManager;

    constructor() {
        /// @dev TO:DO set deployment addresses of the managers in here.

    }

   /*
    *
    *   User and name related functions
    *
    */

    /// @dev records msg.sender as a funder of _name
    /// @dev and adds them to the userList
    function addRecord(uint256 _name) public {
        bool _exists;
        uint256 _index;
        (_exists, _index) = checkForUser(_name);
        if (_exists == false) {
            Users[msg.sender].names.push(_name);
        }

        bool _found = false;
        for (uint i; i < userList.length; i++){
            if(userList[i] == msg.sender){
                _found = true;
                break;
            }
        }
        if (_found = false) {
            userList.push(msg.sender);
        }

    }

    /// @dev Removes from users the record matching _name
    /// @dev Removes user eniretly if no names, balance or interest left.
    function removeRecord(uint256 _name) public {
        bool _exists = false;
        uint256 _index;
        (_exists, _index) = checkForUser(_name);
        if (_exists == true) {
            Users[msg.sender].names[_index] = Users[msg.sender].names[Users[msg.sender].names.length-1];
            Users[msg.sender].names.pop();
        }

        if (Users[msg.sender].names[0] == 0){
            for(uint256 i; i < assetList.length - 1; i++){
                
            }

            for (uint256 i; i < userList.length; i++){
                if (userList[i] == msg.sender){
                    userList[i] = userList[userList.length-1];
                    userList.pop();
                    break;
                }
            }
        }
    }

    /// @dev check if msg.sender is already funding _name
    function checkForName(uint256 _name) public view returns(bool, uint256) {
        bool _found = false;
        uint256 _index = 0;
        for (uint i; i < Users[msg.sender].names.length; i++){
            if(Users[msg.sender].names[i] == _name){
                _index = i;
                _found = true;
                break;
            }
        }
        return (_found, _index);
    }   

    /// @notice returns the number of users funding _name
    function countFunders(uint256 _name) public view returns(uint256){
        uint256 _count;
        for (uint256 i; i < userList.length; i++){
            for (uint256 j; j < Users[userList[i]].names.length; j++){
                if (Users[userList[i]].names[j] = _name){
                    _count++;
                }
            }
        }
        return _count;
    }

/*
    /// @notice returns the number of names being managed
    function countNames() public view returns(uint256){
        uint256 _count;
        uint256[] memory _names = 
        for (uint256 i; i < userList.length; i++){
            for (uint256 j; j < Users[userList[i]].names.length; j++){
                for (uint256 k; k < _names.length; k++){
                   if (Users[userList[i]].names[j] != _names[k]){
                        _count++;
                    } 
                }
                
            }
        }
        return _count;
    } */

    function userExists() public view returns (bool) {
        for (uint256 i; i < userList.length; i++){
            if (userList[i] = msg.sender){
                return true;
            }
        }
        return false;
    }

    /// @dev checks if msg.sender is already funding _name
    function checkForUser(uint256 _name) public view returns(bool, uint256) {
        bool _found = false;
        uint256 _index = 0;
        for (uint i; i < Users[msg.sender].names.length; i++){
            if(Users[msg.sender].names[i] == _name){
                _index = i;
                _found = true;
                break;
            }
        }
        return (_found, _index);
    }

    /*
    *
    *   Investment related functions
    *
    */
    
    function userBalance(address _asset) public view returns(uint128){
        return(Users[msg.sender].balance[_asset]);
    }

    function userInterest(address _asset) public view returns(uint128){
        return(Users[msg.sender].interest[_asset]);
    }

    function balanceTotal(address _asset) public returns(uint256){
        uint256 _total;
        for (uint256 i; i< userList.length; i++){
            _total = _total.add(Users[userList[i]].balance[_asset]);
        }
    }
    function interestTotal(address _asset) public returns(uint256){
        uint256 _total;
        for (uint256 i; i< userList.length; i++){
            _total = _total.add(Users[userList[i]].interest[_asset]);
        }
    }
    /// @dev maybe this is more efficient than the individual functions?
    function sumBalanceAndInterest(address _asset) public returns(uint256){
        uint256 _total;
        for (uint256 i; i< userList.length; i++){
            _total = _total.add(Users[userList[i]].balance[_asset]);
            _total = _total.add(Users[userList[i]].interest[_asset]);
        }
    }

    /// @notice calculates how many extra aTokens we have i.e. interest
    /// @notice divides and adds result to users balances
    /// @dev do we need to collect the dust and distribute that later?
    function calculateInterest(address _asset) public {
        uint256 _interest = investmentManager.getATokenBalance(_asset);
        _interest = _interest.sub(sumBalanceAndInterest(_asset));

        
        uint256 _interestSplit = _interest.div(assets[_asset].userList.length);
        /// @dev we want to leave any dust behind, so mod the _interest before updating the asset interest balance
        /// @dev this is fine because the dust will be collected the next time interest is calculated
        _interest = _interest.sub(_interest.mod(assets[_asset].userList.length));
        assets[_asset].interest = assets[_asset].interest.add(_interest);
        for (uint i; i < assets[_asset].userList.length; i++){
            Users[address(assets[_asset].userList[i])].interest[_asset] = 
            SafeCast.toUint128(uint256(Users[address(assets[_asset].
            userList[i])].interest[_asset]).add(_interestSplit));
        }
    }

    /*
    *
    *   Test/Temporary functions
    *
    */

    function setNameManager(address _address) public onlyOwner {
        nameManager = NameManager(_address);
    }
    function setExchangeManager(address _address) public onlyOwner {
        exchangeManager = ExchangeManager(_address);
    }
    function setInvestmentManager(address _address) public onlyOwner {
        investmentManager = InvestmentManager(_address);
    }

}