// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
//import "@openzeppelin/contracts/utils/SafeCast.sol";
import "interfaces/IOneSplit.sol";
import "interfaces/INameManager.sol";

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
    IOneSplit oneSplit;
    IOneSplitMulti oneSplitMulti;
    IOneSplitConsts oneSplitConsts;
    IERC20 erc20;

    uint256 exchangeParts = 20;
    uint256 exchangeFlags = 0;
    uint256 iterations = 5;
    uint256 percentIncrease = 101;

    constructor() {
        nameManager = NameManager(nameManagerAddress);
        oneSplit = IOneSplit(oneInch);
    }

    /// @dev use our NameManager to grab the 1Inch contract address
    function get1InchAddress() public onlyOwner {
        bytes32 _nameHash = 0;
        string memory _name = "1split";
        oneInch = nameManager.resolveName(_name, _nameHash);
        oneSplit = IOneSplit(oneInch);
    }

    /// @notice currently there's no option on 1inch to select an output value and calculate the input
    /// @notice so we do a test evaluation and use that to figure out the current exchange rate
    /// @notice this usually works but sometimes a different value gives a different exchange rate
    /// @notice so we can try increasing the value by PercentageIncrease a couple of times.
    function getExchangePrice(address _inputToken, uint256 _outputValue, address _outputToken) public view returns(uint256, uint256[] memory){
        IERC20 _inputERC20;
        _inputERC20 = IERC20(_inputToken);
        IERC20 _outputERC20;
        _outputERC20 = IERC20(_outputToken);
        uint256 _unitValue = 10**18;
        uint256 _return;
        (_return,) = oneSplit.getExpectedReturn(_inputERC20, _outputERC20, _unitValue, exchangeParts, exchangeFlags);
        uint256 _inputValue;
        _inputValue = _outputValue.mul(_unitValue);
        _inputValue = _inputValue.div(_return);
        (_return,) = oneSplit.getExpectedReturn(_inputERC20, _outputERC20, _inputValue, exchangeParts, exchangeFlags);
        for(uint256 i; i < iterations; i++){
            if(_outputValue < _return){
                break;
            } else {
                _inputValue = (_inputValue.mul(percentIncrease)).div(100);
                (_return,) = oneSplit.getExpectedReturn(_inputERC20, _outputERC20, _inputValue, exchangeParts, exchangeFlags);
            }
        }
        if(_outputValue < _return){
            return oneSplit.getExpectedReturn(_inputERC20, _outputERC20, _inputValue, exchangeParts, exchangeFlags);
        } else {
            uint256[] memory fail = new uint256[](1);
            return (0,fail);
        }
    }

    function swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256 flags
    )
        external
        payable
        returns(uint256 returnAmount) {


        }

    function updateExchangeParts(uint256 _newParts) public onlyOwner {
        exchangeParts = _newParts;
    }
    function updateExchangeFlags(uint256 _newFlags) public onlyOwner {
        exchangeFlags = _newFlags;
    }
    function updatePercentageIncrease(uint256 _newPercent) public onlyOwner {
        percentIncrease = _newPercent;
    }
    function updateIterations(uint256 _newIterations) public onlyOwner {
        iterations = _newIterations;
    }
    function updateNameManagerAddress(address _nameManager) public onlyOwner {
        nameManager = NameManager(_nameManager);
    }

}