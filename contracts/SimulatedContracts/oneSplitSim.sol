// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/SafeCast.sol";
import "@chainlink/contracts/src/v0.7/interfaces/AggregatorV3Interface.sol";
import "../interfaces/IExchangeManager.sol";


contract oneSplitSim is Ownable {
    address dai = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
    address tusd = 0x016750AC630F711882812f24Dba6c95b9D35856d;
    address uniswap = 0x075A36BA8846C6B6F53644fDd3bf17E5151789DC;
    address usdc = 0xe22da380ee6B445bb8273C81944ADEB6E8450422;
    address usdt = 0x13512979ADE267AB5100878E2e0f485B568328a4;
    address aave = 0xB597cd8D3217ea6477232F9217fa70837ff667Af;

    uint256 roundOffset = 0;

    IExchangeManager exchangeManager;

    function changeOffset(uint256 _offset) external onlyOwner{
        roundOffset = _offset;
    }

    function fetchTokens(address _token) external onlyOwner {
        IERC20 _erc20 = IERC20(_token);
        _erc20.transfer(msg.sender, _erc20.balanceOf(address(this)));
    }

    function retrieveETH() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function setExchangeManager(address payable _exchangeManager) external {
        exchangeManager = IExchangeManager(_exchangeManager);
    }

    receive() external payable {}

    function getpair(address _token) internal view returns(string memory _pair){
        if (_token == dai) {
            _pair = "dai-eth";
        } else if (_token == tusd) {
            _pair = "dai-tusd";
        } else if (_token == uniswap) {
            _pair = "dai-uni";
        } else if (_token == usdc) {
            _pair = "dai-usdc";
        } else if (_token == usdt) {
            _pair = "dai-usdt";
        } else if (_token == aave) {
            _pair = "dai-aave";
        }
    }

    /// @notice Calculate expected returning amount of `destToken`
    /// @param fromToken (IERC20) Address of token or `address(0)` for Ether
    /// @param destToken (IERC20) Address of token or `address(0)` for Ether
    /// @param amount (uint256) Amount for `fromToken`
    /// @param parts (uint256) Number of pieces source volume could be splitted,
    /// works like granularity, higly affects gas usage. Should be called offchain,
    /// but could be called onchain if user swaps not his own funds, but this is still considered as not safe.
    /// @param flags (uint256) Flags for enabling and disabling some features, default 0
    function getExpectedReturn(
        address fromToken,
        address destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags // See constants in IOneSplit.sol
    )
        external
        view
        returns (uint256 returnAmount, uint256[] memory distribution)
    {
        destToken;
        parts;
        flags;
        
        int256 _intPrice;
        uint256 _round;
        uint256 _decimals;
        
        AggregatorV3Interface _aggregator = AggregatorV3Interface(exchangeManager.getOracleAddress(getpair(fromToken)));
        (_round,,,,) = _aggregator.latestRoundData();
        _round = _round - roundOffset;
        (,_intPrice,,,) = _aggregator.getRoundData(uint80(_round));
        _decimals = _aggregator.decimals();
        returnAmount = amount * SafeCast.toUint256(_intPrice);
        returnAmount = returnAmount / (10**_decimals);
        uint256[] memory _distribution = new uint256[](22);
        return (returnAmount, _distribution);
    }

    /// @notice Swap `amount` of `fromToken` to `destToken`
    /// @param fromToken (IERC20) Address of token or `address(0)` for Ether
    /// @param destToken (IERC20) Address of token or `address(0)` for Ether
    /// @param amount (uint256) Amount for `fromToken`
    /// @param minReturn (uint256) Minimum expected return, else revert
    /// @param distribution (uint256[]) Array of weights for volume distribution returned by `getExpectedReturn`
    /// @param flags (uint256) Flags for enabling and disabling some features, default 0
    function swap(
        address fromToken,
        address destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256 flags
    ) external payable returns (uint256 returnAmount) {
        IERC20 _erc20 = IERC20(fromToken);
        _erc20.transferFrom(msg.sender, address(this), amount);
        flags;
        minReturn;
        distribution;

        int256 _intPrice;
        uint256 _round;
        uint256 _decimals;
        AggregatorV3Interface _aggregator = AggregatorV3Interface(exchangeManager.getOracleAddress(getpair(fromToken)));
        (_round,,,,) = _aggregator.latestRoundData();
        _round = _round - roundOffset;
        (,_intPrice,,,) = _aggregator.getRoundData(uint80(_round));
        _decimals = _aggregator.decimals();
        returnAmount = amount * SafeCast.toUint256(_intPrice);
        returnAmount = returnAmount / (10**_decimals);

        if(destToken == address(0)){
            msg.sender.transfer(returnAmount);
        } else {
            _erc20 = IERC20(destToken);
            _erc20.transfer(msg.sender, returnAmount);
        }
        return returnAmount;
    }
}
