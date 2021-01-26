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
    uint256 constant MAX_INT = type(uint256).max;

    modifier onlyUser() {
        require(vault[msg.sender] != address(0), "User not found");
        _;
    }

    /******************************************** 
    *                                           *
    *   User functions                          *
    *                                           *
    ********************************************/

    /// @notice approves transfering tokens from the userVault
    /// @notice to the Aave LendingPool contract
    /// @notice will deploy a new vault if one doesn't exist
    /// @param _asset the contract address of the token to approve
    /// @param _amount the amount to approve in wei
    /// @param _max set to true to ignore amount and approve the max
    function approve(address _asset, uint256 _amount, bool _max) external {
        require(_asset != address(0), "Asset contract can't be the zero address");
        if (vault[msg.sender] == address(0)){
            deployVault();
        }
        investmentManager.approveLendingPool(_asset, vault[msg.sender], _amount, _max);
        approveInvestmentManager(_asset);
        approveVault(_asset);
    }

    /// @notice deposits tokens to the Aave LendingPool contract
    /// @notice updates vault with new balance
    /// @param _asset the contract address of the token to deposit
    /// @param _amount the amount to deposit in wei
    function deposit(address _asset, uint256 _amount) external {
        require(_asset != address(0), "Asset contract can't be the zero address");
        require(_amount > 0, "Amount must be more than 0");
        //require(investmentManager.checkAllowance(_asset) >= _amount, "User not approved to send this amount");
        setBalance(_asset, getBalance(_asset).add(_amount));
        IERC20 _erc20 = IERC20(_asset);
        _erc20.transferFrom(msg.sender, address(this), _amount);
        investmentManager.deposit(_asset, vault[msg.sender], _amount, address(this));
    }

    /// @notice withdraw tokens from the Aave LendingPool contract
    /// @notice updates vault with new balance
    /// @param _asset the contract address of the token to deposit
    /// @param _amount the amount to deposit in wei
    function withdraw(address _asset, uint256 _amount) external {
        require(_asset != address(0));
        require(_amount > 0, "Amount must be more than 0");
        require(getTotal(_asset) > 0, "No balance left to withdraw");
        uint256 _balance = getTotal(_asset);
        if (_amount >= _balance) {
            _amount = MAX_INT;
            _balance = 0;
            setBalance(_asset, _balance);
        } else {
            setBalance(_asset, _balance.sub(_amount));
        }
        IERC20 _erc20 = IERC20(investmentManager.getAToken(_asset));
        _erc20.transferFrom(vault[msg.sender], address(investmentManager), _amount);
        //_erc20.transferFrom(address(this), address(investmentManager), _amount);
        investmentManager.withdraw(_asset, _amount, msg.sender);
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
    function findVault(address _vault) public view returns(address){
        return vault[_vault];
    }
    function approveVault(address _asset) public {
        UserVault _userVault = UserVault(vault[msg.sender]);
        _userVault.approve(investmentManager.getAToken(_asset));
    }

    /// @dev this is stupid, it'll always return msg.sender (hopefully)
    function getOwner() public view onlyUser returns(address){
        UserVault _userVault = UserVault(vault[msg.sender]);
        return _userVault.owner();
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