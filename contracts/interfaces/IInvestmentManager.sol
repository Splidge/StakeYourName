// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IInvestmentManager {
    function recieve() external payable;
    function approveLendingPool(address _asset, address _userVault) external;
    function getAToken(address _asset) external view returns(address);
    function getATokenBalance(address _asset, address _userVault) external view returns(uint256);
    function deposit(address _asset, address _userVault, uint256 _amount) external ;
    function checkAllowance(address _asset) external view returns(uint256);
    function withdraw(address _asset, uint256 _amount, address _user) external;
    function getBalance(address _asset, address _vault) external view returns(uint256);
    function getInterest(address _asset, address _vault) external view returns(uint256);
    function getTotal(address _asset, address _vault) external view returns(uint256);
    function retrieveETH() external;
}
