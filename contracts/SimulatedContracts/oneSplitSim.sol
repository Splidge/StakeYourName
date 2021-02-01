// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract oneSplitSim is Ownable {
    address dai = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
    address tusd = 0x016750AC630F711882812f24Dba6c95b9D35856d;
    address uniswap = 0x075A36BA8846C6B6F53644fDd3bf17E5151789DC;
    address usdc = 0xe22da380ee6B445bb8273C81944ADEB6E8450422;
    address usdt = 0x13512979ADE267AB5100878E2e0f485B568328a4;
    address aave = 0xB597cd8D3217ea6477232F9217fa70837ff667Af;

    uint256 daiRate = 726410000000000;
    uint256 tusdRate = 725880000000000;
    uint256 uniswapRate = 10820000000000000;
    uint256 usdcRate = 723434955112806;
    uint256 usdtRate = 727470000000000;
    uint256 aaveRate = 207400000000000000;

    function fetchTokens(address _token) external onlyOwner {
        IERC20 _erc20 = IERC20(_token);
        _erc20.transfer(msg.sender, _erc20.balanceOf(address(this)));
    }

    function retrieveETH() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    receive() external payable {}

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
        if (fromToken == dai) {
            amount = amount * daiRate;
            amount = amount / 10**18;
        } else if (fromToken == tusd) {
            amount = amount * tusdRate;
            amount = amount / 10**18;
        } else if (fromToken == uniswap) {
            amount = amount * uniswapRate;
            amount = amount / 10**18;
        } else if (fromToken == usdc) {
            amount = amount * usdcRate;
            amount = amount / 10**18;
        } else if (fromToken == usdt) {
            amount = amount * usdtRate;
            amount = amount / 10**18;
        } else if (fromToken == aave) {
            amount = amount * aaveRate;
            amount = amount / 10**18;
        }

        uint256[] memory _distribution = new uint256[](22);
        return (amount, _distribution);
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
        if (fromToken == dai) {
            amount = amount * daiRate;
            amount = amount / 10**18;
        } else if (fromToken == tusd) {
            amount = amount * tusdRate;
            amount = amount / 10**18;
        } else if (fromToken == uniswap) {
            amount = amount * uniswapRate;
            amount = amount / 10**18;
        } else if (fromToken == usdc) {
            amount = amount * usdcRate;
            amount = amount / 10**18;
        } else if (fromToken == usdt) {
            amount = amount * usdtRate;
            amount = amount / 10**18;
        } else if (fromToken == aave) {
            amount = amount * aaveRate;
            amount = amount / 10**18;
        }
        if(destToken == address(0)){
            msg.sender.transfer(amount);
        } 
        return (amount);
    }
}
