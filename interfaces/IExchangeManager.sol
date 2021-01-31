// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

  /**
   * @title Manages exchanging tokens and ETH
   * @notice part of the StakeYourName DApp
   * @author Daniel Chilvers
   **/
interface ExchangeManager {

    receive() external payable;
    function getPrice(address _from, address _to) external view returns(uint256 _price, uint256 _decimals);
    function getOracleAddress(string memory _pair) external view returns(address);
    function assembleTokenEthPair(address _from, address _to) external view returns(string memory);
    function get1InchAddress() external;
    function checkAvailiableFunds(uint256 _cost, address _vault) external view returns(bool _accept, address _token, uint256[] memory _distribution);
    function estimateFunds(uint256 _cost, address _vault) external view returns(bool _accept, address _token);
    function estimateSpecificAssetFunds(
        uint256 _cost, 
        address _vault, 
        address _asset) 
        external view 
        returns(bool _accept);
    function getExchangePrice(
        address _inputToken, 
        uint256 _outputValue, 
        address _outputToken) 
        external 
        view 
        returns
    (
        uint256 _inputValue, 
        uint256[] memory _distribution
    );
    function swap(
        address _fromToken,
        address _destToken,
        uint256 _amount,
        uint256 _minReturn,
        uint256[] memory _distribution,
        uint256 _flags
    )
        external
        payable
        returns(uint256 _returnAmount);
    function updateExchangeParts(uint256 _newParts) external;
    function updateExchangeFlags(uint256 _newFlags) external;
    function updatePercentageIncrease(uint256 _newPercent) external;
    function updateIterations(uint256 _newIterations) external;
    function updateNameManagerAddress(address payable _nameManager) external;
    function updateFresh(uint256 _fresh) external;
    function updateMargin(uint256 _margin) external;
    function updateSlippage(uint256 _slippage) external;
    function updateEstimateSlippage(uint256 _estimateSlippage) external;
    function retrieveETH() external;
    function setOneSplitAddress(address _oneSplit) external;
    function updateChainID(uint256 _chainID) external;
}