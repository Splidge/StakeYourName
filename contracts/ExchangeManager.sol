// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/SafeCast.sol";
import "interfaces/IOneSplit.sol";
import "interfaces/IUserVault.sol";
import "interfaces/INameManager.sol";
import "interfaces/IInvestmentManager.sol";
import "@chainlink/contracts/v0.7/interfaces/AggregatorV3Interface.sol";

  /**
   * @title Manages exchanging tokens and ETH
   * @notice part of the StakeYourName DApp
   * @author Daniel Chilvers
   **/
contract ExchangeManager is Ownable {

    using SafeMath for uint256;

    address internal zeroAddress = address(0);
    address internal oneInch = zeroAddress;
    ///@dev this is not the final NameManager address, update later
    address internal nameManagerAddress = 0xbC86029dbC214939a3c5d383d0C245d5B75538C0;

    NameManager nameManager;
    InvestmentManager investmentManager;
    IOneSplit oneSplit;
    IOneSplitMulti oneSplitMulti;
    IOneSplitConsts oneSplitConsts;
    IERC20 erc20;

    uint256 exchangeParts = 20;
    uint256 exchangeFlags = 0;
    uint256 iterations = 5;
    uint256 percentIncrease = 101;
    uint256 ChainID;
    uint256 fresh = 2 hours;
    uint256 margin = 105;
    uint256 slippage = 95;
    uint256 estimateSlippage = 105;

    constructor(uint _networkID) {
        ChainID =_networkID;
        nameManager = NameManager(nameManagerAddress);
        oneSplit = IOneSplit(oneInch);
    }

    function getPrice(address _from, address _to) public view returns(uint256 _price, uint256 _decimals){
        uint256 _time;
        int256 _intPrice;
        address _address = getOracleAddress(assembleTokenEthPair(_from, _to));
        AggregatorV3Interface _aggregator = AggregatorV3Interface(_address);
        (,_intPrice,,_time,) = _aggregator.latestRoundData();
        require(block.timestamp - _time > fresh);
        _decimals = _aggregator.decimals();
        _price = SafeCast.toUint256(_intPrice);
    }

    function getOracleAddress(string memory _pair) public view returns(address) {
        if (ChainID == 1){
            string[] memory _name = new string[](3);
            _name[0] = "eth";
            _name[1] = "data";
            _name[3] = _pair;
            return nameManager.resolveName(_name);
        } else {
            return 0x122eb74f9d0F1a5ed587F43D120C1c2BbDb9360B;
        }
    }

    function assembleTokenEthPair(address _from, address _to) public view returns(string memory){
        string memory _fromSymbol;
        string memory _toSymbol;
        _fromSymbol = toLower(getTokenSymbol(_from));
        if(_to == zeroAddress){
            _toSymbol = "eth";
        } else {
            _toSymbol = toLower(getTokenSymbol(_to));
        }
        return string(abi.encodePacked(_fromSymbol,"-",_toSymbol));
    }

    function getTokenSymbol(address _asset) internal view returns (string memory){
        IERC20 _erc20 = IERC20(_asset);
        string memory _symbol = _erc20.symbol();
        return _symbol;
    }

    function toLower(string memory str) internal pure returns (string memory) {
		bytes memory bStr = bytes(str);
		bytes memory bLower = new bytes(bStr.length);
		for (uint i = 0; i < bStr.length; i++) {
			// Uppercase character...
			if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
				// So we add 32 to make it lowercase
				bLower[i] = bytes1(uint8(bStr[i]) + 32);
			} else {
				bLower[i] = bStr[i];
			}
		}
		return string(bLower);
	}


    /// @dev use our NameManager to grab the 1Inch contract address
    function get1InchAddress() public onlyOwner {
        string[] memory _name = new string[](2);
        _name[0] = "eth";
        _name[1] = "1split";
        oneInch = nameManager.resolveName(_name);
        oneSplit = IOneSplit(oneInch);
    }

    function checkAvailiableFunds(uint256 _cost, address _vault) public view returns(bool _accept, address _token, uint256[] memory _distribution){
        UserVault _userVault = UserVault(_vault);
        uint256[] memory _distributionArray = new uint256[](22);
        uint256 _price;
        for (uint256 i; i < _userVault.assets().length; i++){
            (_price, _distributionArray) = getExchangePrice(_userVault.assets()[i] , _cost, zeroAddress);
            if(_price != 0){
                return (true, _userVault.assets()[i], _distributionArray);
            }
        }
        return (false, zeroAddress, _distributionArray);
    }

    /// @dev estimate if the vault will have enough funds to complete the purshase
    function estimateFunds(uint256 _cost, address _vault) public view returns(bool _accept, address _token){
        UserVault _userVault = UserVault(_vault);
        for (uint256 i; i < _userVault.assets().length; i++){
            (uint256 _oraclePrice, uint256 _decimals) = getPrice(_userVault.assets()[i], zeroAddress );
            uint256 _estimatedInput = _oraclePrice.mul(_cost);
            _estimatedInput = (_estimatedInput.mul( estimateSlippage )).div(100);
            _estimatedInput = _estimatedInput.div(10**_decimals);
            if (_estimatedInput > investmentManager.getInterest(_userVault.assets()[i], _vault)){
                return(true, _userVault.assets()[i]);
            }
        }
        return(false,zeroAddress);
    }

    /// @notice currently there's no option on 1inch to select an output value and calculate the input
    /// @notice so we use chainlink to give us a good estimate, we can then adjust that value to seek
    /// @notice the output value we want. Only allowing the value to creep a set amount to make sure
    /// @notice we are getting a reasonable price.
    function getExchangePrice(address _inputToken, uint256 _outputValue, address _outputToken) public view returns(uint256 _return, uint256[] memory _distribution){
        (uint256 _oraclePrice, uint256 _decimals) = getPrice(_inputToken, _outputToken);
        uint256 _adjOutputValue = _outputValue.div(10**_decimals);
        uint256 _estimatedInput = _oraclePrice.mul(_adjOutputValue);
        (_return, _distribution) = oneSplit.getExpectedReturn(_inputToken, _outputToken, _estimatedInput, exchangeParts, exchangeFlags);
        uint256 _difference = (_return.mul(100)).div(_outputValue);
        require(_difference < margin, 'Possible oracle error, too much return on exchange');
        require(_difference > slippage, 'Exchange rate unfavourable');
        if (_difference < 100){
            /// @dev we're not getting enough return, but it's close so lets try again.
            _estimatedInput = (_estimatedInput.mul(_difference)).div(100);
            (_return, _distribution) = oneSplit.getExpectedReturn(_inputToken, _outputToken, _estimatedInput, exchangeParts, exchangeFlags);
            _difference = (_return.mul(100)).div(_outputValue);
            require(_difference < margin, 'Exchange error, too much return on exchange');
            if (_return > _outputValue){
                return (_return, _distribution);
            }
            require(true, 'Exchange failed after second attempt');
        } else {
            /// @dev Goldilocks, not too much, not too little.
            return (_return, _distribution);
        }
    }

    function swap(
        address fromToken,
        address destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256 flags
    )
        external
        payable
        returns(uint256 returnAmount) {


        }

    function updateExchangeParts(uint256 _newParts) external onlyOwner {
        exchangeParts = _newParts;
    }
    function updateExchangeFlags(uint256 _newFlags) external onlyOwner {
        exchangeFlags = _newFlags;
    }
    function updatePercentageIncrease(uint256 _newPercent) external onlyOwner {
        percentIncrease = _newPercent;
    }
    function updateIterations(uint256 _newIterations) external onlyOwner {
        iterations = _newIterations;
    }
    function updateNameManagerAddress(address _nameManager) external onlyOwner {
        nameManager = NameManager(_nameManager);
    }
    function updateFresh(uint256 _fresh) external onlyOwner {
        fresh = _fresh;
    }
    function updateMargin(uint256 _margin) external onlyOwner {
        margin = _margin;
    }
    function updateSlippage(uint256 _slippage) external onlyOwner {
        slippage = _slippage;
    }   
    function updateEstimateSlippage(uint256 _estimateSlippage) external onlyOwner {
        estimateSlippage = _estimateSlippage;
    }

    /// @dev for quick testing, later use truffle to pass this in.
    function updateChainID(uint256 _chainID) external onlyOwner {
        ChainID = _chainID;
    }
}