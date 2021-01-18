// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

//@Created by Daniel Chilvers
interface LendingPool {

    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external;
}