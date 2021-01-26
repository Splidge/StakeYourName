// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ExchangeManager {
    function get1InchAddress() external ;
    
    function getExchangePrice(
        uint256 _inputValue, 
        address _inputToken, 
        uint256 _outputValue, 
        address _outputToken
    ) 
        external 
        view 
        returns(uint256, uint256[] memory);

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
        returns(uint256 returnAmount);

    function updateExchangeParts(uint256 _newParts) external ;
    function updateExchangeFlags(uint256 _newFlags) external ;


}