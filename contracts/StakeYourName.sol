// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "interfaces/INameManager.sol";
import "interfaces/IInvestmentManager.sol";
import "interfaces/IExchangeManager.sol";
import "interfaces/IUserVault.sol";
//import "interfaces/ENS_BulkRenewal.sol";
//import "interfaces/ENS_Resolver.sol";

/// @title StakeYourName - Main Contract
/// @notice Handles interations between the users and
/// @notice other StakeYourName contracts.
/// @author Daniel Chilvers

contract StakeYourName is Ownable {

    NameManager nameManager;
    ExchangeManager exchangeManager;
    InvestmentManager investmentManager;
    //IERC20 token;

    
    constructor() {
        /// @dev TO:DO set deployment addresses of the managers in here.

    }

    using SafeMath for uint256;
    address internal masterVault;
    mapping (address => address) internal vault;
    uint256 public referralCode = 0;

    modifier onlyUser() {
        require(vault[msg.sender] != address(0), "User not found");
        _;
    }

    /******************************************** 
    *                                           *
    *   User functions                          *
    *                                           *
    ********************************************/

    function deposit(address _asset, uint256 _amount) public {
        require(_amount > 0, "Deposit amount must be more than 0");
        require(investmentManager.checkAllowance(_asset) >= _amount, "User not approved to send this amount");
        if (vault[msg.sender] == address(0)){
            deployVault();
        }
        IERC20 _erc20 = IERC20(_asset);
        _erc20.transferFrom(msg.sender, address(this), _amount);
        lendingPool.deposit(_asset, _amount, vault[msg.sender], referralCode);
    }





    /******************************************** 
    *                                           *
    *   User Vault deployment and functions.    *
    *                                           *
    ********************************************/

    /// @notice clone the master vault contract
    function deployVault() public{
        bytes32 _salt = keccak256(abi.encodePacked(msg.sender));
        vault[msg.sender] = Clones.cloneDeterministic(masterVault, _salt);
        UserVault _userVault = UserVault(vault[msg.sender]);
        _userVault.initialize();
    }

    function setMasterVault(address _vault) public onlyOwner {
        masterVault = _vault;
    }
    function setBalance(address _asset, uint256 _balance) public onlyUser{
        UserVault _userVault = UserVault(vault[msg.sender]);
        _userVault.setBalance(_asset, _balance);
    }
    function getBalance(address _asset) public view onlyUser returns(uint256){
        UserVault _userVault = UserVault(vault[msg.sender]);
        return _userVault.balance(_asset);
    }
    function getInterest(address _asset) public view onlyUser returns(uint256) {
        UserVault _userVault = UserVault(vault[msg.sender]);
        uint256 _tokenBalance = investmentManager.getATokenBalance(_asset, vault[msg.sender]);
        return _tokenBalance.sub(_userVault.balance(_asset));
    }
    function getTotal(address _asset) public view onlyUser returns(uint256){
        return (getBalance(_asset).add(getInterest(_asset)));
    }

    /// @dev this is stupid, it'll always return msg.sender (hopefully)
    function getOwner() public view onlyUser returns(address){
        UserVault _userVault = UserVault(vault[msg.sender]);
        return _userVault.owner();
    }


    /******************************************** 
    *                                           *
    *   Test and/or temporary functions.        *
    *                                           *
    ********************************************/

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