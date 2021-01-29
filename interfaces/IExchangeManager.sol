// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ExchangeManager {
    function get1InchAddress() external ;
    
    function getExchangePrice(
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

    function checkAvailiableFunds(
            uint256 _cost, 
            address _vault
        ) 
        external 
        view 
        returns(
            bool _accept, 
            address _token, 
            uint256[] memory _distribution
    );

    function estimateFunds(uint256 _cost, address _vault) external view returns(bool _accept, address _token);
    function estimateSpecificAssetFunds(uint256 _cost, address _vault, address _asset) external view returns(bool _accept);
    function updateExchangeParts(uint256 _newParts) external;
    function updateExchangeFlags(uint256 _newFlags) external;
    function updatePercentageIncrease(uint256 _newPercent) external;
    function updateIterations(uint256 _newIterations) external;
    function updateNameManagerAddress(address _nameManager) external;

}