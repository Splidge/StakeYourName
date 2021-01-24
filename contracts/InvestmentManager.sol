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

    /// @dev addresses saved here for testing, in final version the
    /// @dev addresses will be passed in from the front end.
    address internal DAIContract = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal USDCContract = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    uint16 referralCode = 0;
    uint256 constant MAX_INT = type(uint256).max;

    /// @notice User data, maps an assest contract address to their balance, interest earnt
    /// @notice and if they've locked the original investment (no auto-switching, no loss investement)
    /// @dev we can increase balance to uint256, changing to mappings removed the packing benefits
    struct User {
        mapping (address => uint128) balance;
        mapping (address => uint128) interest;
        mapping (address => bool) locked;
    }

    /// @dev map user addresses to our struct above
    mapping (address => User) Users;

    /// @dev balance, how many of each token bought
    /// @dev interest, how much interest earnt so far
    /// @dev interestCalcualtionTime, block.timestamp of last calculation
    /// @dev TO:DO pack this struct better
    struct Asset {
        uint256 balance;
        uint256 interest;
        //uint256 interestCalculationTime;
        address[] userList;
    }

    mapping (address => Asset) assets;


    /// @dev save a list of any assests we've puchased
    address[] public assetList;
    /// @dev save a list of users that have purchased asset
    address[] public userList;

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
    /// @dev this needs to be called for each new asset purchased
    function approveLendingPool(address _asset) public {
        ierc20 = IERC20(_asset);
        ierc20.approve(lendingPooladdress , MAX_INT);
    }

    function userBalance(address _asset) public view returns(uint128){
        return(Users[msg.sender].balance[_asset]);
    }

    function userInterest(address _asset) public view returns(uint128){
        return(Users[msg.sender].interest[_asset]);
    }

    /// @notice calculates how many extra aTokens we have i.e. interest
    /// @notice divides and adds result to users balances
    /// @dev do we need to collect the dust and distribute that later?
    function calculateInterest(address _asset) public {
        //require(assets[_asset].balance != 0);
        address _aTokenAddress;
        (_aTokenAddress,,) = protocolDataProvider.getReserveTokensAddresses(_asset);
        //_aTokenAddress = 0xdCf0aF9e59C002FA3AA091a46196b37530FD48a8;
        ierc20 = IERC20(_aTokenAddress);
        uint256 _interest = ierc20.balanceOf(address(this));
        _interest = _interest.sub(assets[_asset].balance);
        _interest = _interest.sub(assets[_asset].interest);
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

    /// @notice just does a deposit, doesn't record to any users balance
    /// @dev just for testing, remove later
    function depositTest(address _asset, uint256 _amount) public {
        ierc20 = IERC20(_asset);
        ierc20.transferFrom(msg.sender, address(this), _amount);
        lendingPool.deposit(_asset, _amount, address(this) , referralCode);
        assets[_asset].balance = assets[_asset].balance.add(_amount);
    }

    /// @notice just does a withdrawl, doesn't record to a users balance
    /// @dev just for testing, remove later
    function withdrawTest(address _asset, uint256 _amount) public onlyOwner {
        lendingPool.withdraw(_asset, _amount, msg.sender);
    }


    /// @dev this isn't how it works, the user needs to approve directly to the asset contract
    function approveDeposit(address _asset, uint128 _amount) public {
        require(_asset != address(0));
        require(_amount > 0);
        ierc20 = IERC20(_asset);
        ierc20.approve(address(this), _amount);
        if (!checkAssetList(_asset)) {
            addAsset(_asset);
        }
    }

    /// @notice checks if we've purchased this assest before, make internal later
    function checkAssetList(address _asset) public view returns(bool){
        for (uint i; i < assetList.length; i++ ){
            if(address(assetList[i]) == _asset){
                return true;
            }
        }
        return false;
    }

    /// @notice adds an _asset to the assetList and approves sending to the lendingPool
    function addAsset(address _asset) public onlyOwner{
        assetList.push(_asset);
        approveLendingPool(_asset);
        //approveATokenBurn(_asset, MAX_INT);
    }

    /// @notice checks if this user has purchased this asset previously
    function checkUserList(address _asset) public view returns(bool){
        for (uint i; i < assets[_asset].userList.length; i++ ){
            if(assets[_asset].userList[i] == msg.sender){
                return true;
            }
        }
        return false;
    }

    /// @notice records that the user has now purchased _asset
    function addUser(address _asset) public onlyOwner{
        assets[_asset].userList.push(msg.sender);
        //approveLendingPool(_asset);
        //approveATokenBurn(_asset, MAX_INT);
    }

    function checkAllowance (address _asset) public returns(uint256){
        ierc20 = IERC20(_asset);
        return ierc20.allowance(msg.sender, address(this));
    }

    /// @dev TO:DO add some more requires to potentially save gas
    function deposit(address _asset, uint128 _amount) public {
        require(_asset != address(0));
        require(checkAllowance(_asset) >= _amount, "User not approved to send this amount");
        require(_amount > 0, "Deposit must be non-zero");
        if (!checkAssetList(_asset)) {
            addAsset(_asset);
        }
        ierc20 = IERC20(_asset);
        ierc20.transferFrom(msg.sender, address(this), _amount);
        lendingPool.deposit(_asset, _amount, address(this) , referralCode);
        assets[_asset].balance = assets[_asset].balance.add(_amount);
        if (!checkUserList(_asset)) {
            addUser(_asset);
        }
        Users[msg.sender].balance[_asset] = safeAddUint128(Users[msg.sender].balance[_asset], _amount );
    }

    /// @dev don't think we need to do this!?
    function approveATokenBurn(address _asset, uint256 _amount) public {
        address _aTokenAddress;
        (_aTokenAddress,,) = protocolDataProvider.getReserveTokensAddresses(_asset);
        ierc20 = IERC20(_aTokenAddress);
        ierc20.approve(lendingPooladdress , _amount);
    }

    ///@dev current implemnetation withdraws balance before deposit.
    function withdraw(address _asset, uint128 _amount) public {
        require(_asset != address(0));
        require(_amount > 0);
        calculateInterest(_asset);
        uint128 _maxWithdrawl = safeAddUint128(Users[msg.sender].balance[_asset],Users[msg.sender].interest[_asset]);
        uint128 _withdrawl = 0;
        uint128 _balanceReduction = 0;
        uint128 _interestReduction = 0;
        if (_amount > _maxWithdrawl) {
            _balanceReduction = Users[msg.sender].balance[_asset];
            _interestReduction = Users[msg.sender].interest[_asset];
            Users[msg.sender].balance[_asset] = 0;
            Users[msg.sender].interest[_asset] = 0;
            _withdrawl = _maxWithdrawl;
        } else if (_amount > Users[msg.sender].balance[_asset]) {
            _balanceReduction = Users[msg.sender].balance[_asset];
            _interestReduction = safeSubUint128(_amount, Users[msg.sender].balance[_asset]);           
            Users[msg.sender].interest[_asset] = safeSubUint128(Users[msg.sender].interest[_asset],safeSubUint128(_amount, Users[msg.sender].balance[_asset]));
            Users[msg.sender].balance[_asset] = 0;
            _withdrawl = _amount;
        } else {
            _balanceReduction = _amount;
            Users[msg.sender].balance[_asset] = safeSubUint128(Users[msg.sender].balance[_asset], _amount);
            _withdrawl = _amount;
        }
        lendingPool.withdraw(_asset, _withdrawl, msg.sender);
        assets[_asset].balance = assets[_asset].balance.sub(_balanceReduction);
        assets[_asset].interest = assets[_asset].interest.sub(_interestReduction);
    }

    function convertInterestToBalance(address _asset, uint128 _amount) public {
        require(_asset != address(0));
        require(_amount > 0);
        calculateInterest(_asset);
        uint128 _check = userTotal(_asset);
        if (_amount > Users[msg.sender].interest[_asset]){
            assets[_asset].balance = assets[_asset].balance.add(Users[msg.sender].interest[_asset]);
            assets[_asset].interest = assets[_asset].interest.sub(Users[msg.sender].interest[_asset]);
            Users[msg.sender].balance[_asset] = safeAddUint128(Users[msg.sender].balance[_asset], Users[msg.sender].interest[_asset]);
            Users[msg.sender].interest[_asset] = 0;    
        } else {
            Users[msg.sender].interest[_asset] = safeSubUint128(Users[msg.sender].interest[_asset], _amount);
            Users[msg.sender].balance[_asset] = safeAddUint128(Users[msg.sender].balance[_asset], _amount);
            assets[_asset].balance = assets[_asset].balance.add(_amount);
            assets[_asset].interest = assets[_asset].interest.sub(_amount);   
        }
        assert(_check == userTotal(_asset));
    }

    /// @dev only call this after calculateInterest()
    function userTotal(address _asset) public view returns(uint128) {
        return(safeAddUint128(Users[msg.sender].balance[_asset], Users[msg.sender].interest[_asset]));
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
    
    function checkProtocolDataProvider() public view returns(address){
        return (address(protocolDataProvider));
    }

    function updateProtocolDataProvider(bytes1 _bytes) public returns(address, bytes32){
        protocolDataProvider = IProtocolDataProvider(lendingPoolAddressesProvider.getAddress(_bytes));
        return (address(protocolDataProvider),_bytes);
    }

    function checkaTokenAddress(address _asset) public view returns(address){
        address _aTokenAddress;
        (_aTokenAddress,,) = protocolDataProvider.getReserveTokensAddresses(_asset);
        return (address(_aTokenAddress));
    }

    /// @notice update the lending pool address from the address provider
    function updateLendingPoolAddress() public onlyOwner returns(address){
        lendingPooladdress = lendingPoolAddressesProvider.getLendingPool();
        lendingPool = ILendingPool(lendingPooladdress);
        emit debug(lendingPooladdress, 10);
        return (lendingPooladdress);
    }

}