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

    
    constructor() {
        /// @dev TO:DO set deployment addresses of the managers in here.

    }

    using SafeMath for uint256;
    address internal masterVault;
    address[] internal users;
    address internal zeroAddress = 0x0000000000000000000000000000000000000000;
    mapping (address => address) internal vault;
    uint256 public referralCode = 0;
    uint256 constant MAX_INT = type(uint256).max;
    uint256 internal MIN_APPROVAL = type(uint256).max/2;
    uint256 internal recordNumber;
    uint256 internal recordIncrement = 100;

    /// @notice only allow users with an active vault to do these functions
    modifier onlyUser() {
        require(vault[msg.sender] != address(0), "User not found");
        _;
    }

    /******************************************** 
    *                                           *
    *   User functions                          *
    *                                           *
    ********************************************/

    function addName(uint256 _name) external onlyUser {
        UserVault _userVault = UserVault(vault[msg.sender]);
        _userVault.addName(_name);
    }

    function addMultipleNames(uint256[] calldata _names) external onlyUser {
        UserVault _userVault = UserVault(vault[msg.sender]);
        _userVault.addMultipleNames(_names);
    }

    function removeName(uint256 _name) external onlyUser {
        UserVault _userVault = UserVault(vault[msg.sender]);
        _userVault.removeName(_name);        
    }

    function removeMultipleNames(uint256[] calldata _names) external onlyUser {
        UserVault _userVault = UserVault(vault[msg.sender]);
        _userVault.removeMultipleNames(_names);
    }

    /// @notice deposits tokens to the Aave LendingPool contract
    /// @notice updates vault with new balance
    /// @param _asset the contract address of the token to deposit
    /// @param _amount the amount to deposit in wei
    /// @param _newUser if true this user is added to the userList
    function deposit(address _asset, uint256 _amount, bool _newUser) external {
        require(_asset != address(0), "Asset contract can't be the zero address");
        require(_amount > 0, "Amount must be more than 0");
        IERC20 _erc20 = IERC20(_asset);
        require( _erc20.allowance(msg.sender, address(this)) >= _amount, "User not approved to send this amount");
        if (vault[msg.sender] == address(0)){
            deployVault();
        }
        if (_newUser = true){addUser();}
        vaultAddAsset(_asset);
        approveVault(_asset);
        investmentManager.approveLendingPool(_asset, vault[msg.sender]);
        setBalance(_asset, investmentManager.getBalance(_asset, msg.sender).add(_amount));
        _erc20.transferFrom(msg.sender, address(investmentManager), _amount);
        investmentManager.deposit(_asset, vault[msg.sender], _amount);
    }

    /// @notice withdraw tokens from the Aave LendingPool contract
    /// @notice updates vault with new balance
    /// @param _asset the contract address of the token to deposit
    /// @param _amount the amount to deposit in wei
    function withdraw(address _asset, uint256 _amount) external onlyUser {
        require(_asset != address(0));
        require(_amount > 0, "Amount must be more than 0");
        uint256 _balance = investmentManager.getTotal(_asset, msg.sender);
        require(_balance > 0, "No balance left to withdraw");
        uint256 _transfer = 0;
        if (_amount > _balance) {
            _amount = _balance;
            _transfer = MAX_INT;
            _balance = 0;
            setBalance(_asset, _balance);
            vaultRemoveAsset(_asset);
        } else {
            _transfer = _amount;
            setBalance(_asset, _balance.sub(_amount));
        }
        IERC20 _erc20 = IERC20(investmentManager.getAToken(_asset));
        _erc20.transferFrom(vault[msg.sender], address(investmentManager), _amount);
        investmentManager.withdraw(_asset, _transfer, msg.sender);
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
    function findVault(address _vault) public view returns(address){
        return vault[_vault];
    }
    function approveVault(address _asset) public {
        UserVault _userVault = UserVault(vault[msg.sender]);
        _userVault.approve(investmentManager.getAToken(_asset));
    }
    function vaultAddAsset(address _asset) public {
        UserVault _userVault = UserVault(vault[msg.sender]);
        _userVault.addAsset(_asset);
    }
    function vaultRemoveAsset(address _asset) public {
        UserVault _userVault = UserVault(vault[msg.sender]);
        _userVault.removeAsset(_asset);
    }

    function addUser() internal {
        bool _found = false;
        for (uint256 i; i < users.length; i++){
            if(users[i] == msg.sender){
                _found = true;
            }
        }
        if (_found = false){
            users.push(msg.sender); 
        }       
    }

    /// @dev this is stupid, it'll always return msg.sender (hopefully)
    function getOwner() public view onlyUser returns(address){
        UserVault _userVault = UserVault(vault[msg.sender]);
        return _userVault.owner();
    }

    /******************************************** 
    *                                           *
    *   Name functions                          *
    *                                           *
    ********************************************/

    /// @dev lets check each user to see if they have any names that need renewing
    /// @dev then check if that user has the funds to pay for the names
    /// @dev if they do then add them to be processed, otherwise leave it for later.
    function renewNames() public view {
        bool _success = false;
        address _asset;
        for(uint256 i; i < users.length; i++){
            UserVault _userVault = UserVault(vault[users[i]]);
            if(_userVault.names().length != 0 && _userVault.assets().length != 0){
                uint256 _cost;
                uint256[] memory _names = new uint256[](_userVault.names().length);
                if(_success == false){
                    (_names,_cost) = nameManager.checkForRenewals(_userVault.names());
                    (_success, _asset) = exchangeManager.estimateFunds(_cost, users[i]);
                } else {
                    for(uint256 j; j < _userVault.assets().length; j++){
                        if (_userVault.assets()[i] == _asset){
                            uint256 _addCost;
                            uint256[] memory _addNames = new uint256[](_userVault.names().length);
                            (_addNames,_addCost) = nameManager.checkForRenewals(_userVault.names());
                             exchangeManager.estimateSpecificAssetFunds(_addCost,users[i],_asset);

                        }
                    }
                }
            } 
        }

    }

    /******************************************** 
    *                                           *
    *   Exchange functions                      *
    *                                           *
    ********************************************/
/*
    function checkAvailiableFunds(uint256 _cost, address _user) public view returns(bool _accept, address _token, uint256[] memory _distribution){
        UserVault _userVault = UserVault(vault[_user]);
        uint256[] memory _distributionArray = new uint256[](22);
        uint256 _price;
        for (uint256 i; i < _userVault.assets().length; i++){
            (_price, _distributionArray) = exchangeManager.getExchangePrice(_userVault.assets()[i] , _cost, zeroAddress);
            if(_price != 0){
                return (true, _userVault.assets()[i], _distributionArray);
            }
        }
        return (false, zeroAddress, _distributionArray);
    }
*/
    function swapAssets() public view {

    }

    /******************************************** 
    *                                           *
    *   Admin functions                         *
    *                                           *
    ********************************************/

    function updateReferral(uint256 _ref) external onlyOwner {
        referralCode = _ref;
    }


    /******************************************** 
    *                                           *
    *   Test and/or temporary functions.        *
    *                                           *
    ********************************************/

    function setNameManager(address _address) external onlyOwner {
        nameManager = NameManager(_address);
    }
    function setExchangeManager(address _address) external onlyOwner {
        exchangeManager = ExchangeManager(_address);
    }
    function setInvestmentManager(address _address) external onlyOwner {
        investmentManager = InvestmentManager(_address);
    }
    function approveInvestmentManager(address _asset) public onlyOwner {
        IERC20 _erc20 = IERC20(_asset);
        _erc20.approve(address(investmentManager), MAX_INT);
    }

}