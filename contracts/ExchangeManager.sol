// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/SafeCast.sol";
import "interfaces/IOneSplit.sol";
import "interfaces/INameManager.sol";

  /**
   * @title Manages exchanging tokens and ETH
   * @notice part of the StakeYourName DApp
   * @author Daniel Chilvers
   **/
contract ExchangeManager is Ownable {
    address internal zeroAddress = address(0);
    address internal oneInch = zeroAddress;
    ///@dev this is not the final NameManager address, update later
    address internal nameManagerAddress = 0xbC86029dbC214939a3c5d383d0C245d5B75538C0;

    NameManager nameManager;
    IOneSplit oneSplit;
    IOneSplitMulti oneSplitMulti;
    IOneSplitConsts oneSplitConsts;

    uint256 exchangeParts = 20;
    uint256 exchangeFlags = 0;

    constructor() {
        nameManager = NameManager(nameManagerAddress);
        oneSplit = IOneSplit(oneInch);
    }

    /// @dev use our NameManager to grab the 1Inch contract address
    function get1InchAddress() public onlyOwner {
        bytes32 _nameHash = 0;
        string _name = "1split";
        oneInch = nameManager.resolveName(_name, _nameHash);
        oneSplit = IOneSplit(oneInch);
    }

    

    function getExchangePrice(uint256 _inputValue, address _inputToken, uint256 _outputValue, address _outputToken) public view returns(uint256, uint256[] memory) {
        return oneSplit.getExpectedReturn(_inputToken, _outputToken, _inputValue, exchangeParts, exchangeFlags);
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

}