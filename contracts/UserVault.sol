// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

  /**
   * @title UserVault
   * @notice a personal asset vault for each user
   * @notice part of the StakeYourName DApp
   * @author Daniel Chilvers
   **/

import "@openzeppelin/contracts/proxy/Initializable.sol";

contract UserVault is Initializable{

    address public owner;
    mapping (address => uint256) public balance;

    uint256 total;
    
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function initialize() public initializer{
        address msgSender = msg.sender;
        owner = msgSender;
    }

    function setBalance(address _asset, uint256 _balance) public onlyOwner returns(uint256){
         return balance[_asset] = _balance;
    }
}