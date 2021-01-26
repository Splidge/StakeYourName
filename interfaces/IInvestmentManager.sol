// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface InvestmentManager {

    function approveLendingPool(address _asset, address _userVault, uint256 _amount, bool _max) external;
    function getAToken(address _asset) external view returns(address);
    function getATokenBalance(address _asset, address _userVault) external view returns(uint256);
    function deposit(address _asset, address _userVault, uint256 _amount, address _from) external ;
    function checkAllowance(address _asset) external view returns(uint256);
    function withdraw(address _asset, uint256 _amount, address _user) external;
}
