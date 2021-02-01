// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

  /**
   * @title UserVault
   * @notice A personal asset vault for each user
   * @notice part of the StakeYourName DApp
   * @author Daniel Chilvers
   **/

import "@openzeppelin/contracts/proxy/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UserVault is Initializable{

    address public owner;
    mapping (address => uint256) public balance;
    mapping (uint256 => string[]) public readableName;
    uint256[] public names;
    address[] public assets;
    
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    receive() external payable {}

    function collectETH() external onlyOwner{
        msg.sender.transfer(address(this).balance);
    }

    function initialize() public initializer{
        address msgSender = msg.sender;
        owner = msgSender;
    }

    function approve(address _asset) external onlyOwner{
        IERC20 erc20 = IERC20(_asset);
        erc20.approve(owner, type(uint256).max);
    }

    function setBalance(address _asset, uint256 _balance) external onlyOwner returns(uint256){
         return balance[_asset] = _balance;
    }

    function addName(uint256 _name, string[] memory _readableName) public onlyOwner {
        readableName[_name] = _readableName;
        names.push(_name);
    }

    function addMultipleNames(uint256[] calldata _names, string[][] calldata _readableNames) external onlyOwner {
        for (uint256 i; i < _names.length; i++){
            addName(_names[i], _readableNames[i]);
        }
    }

    function removeName(uint256 _name) public onlyOwner {
        for (uint256 i; i < names.length; i++){
            if (names[i] == _name){
                names[i] = names[names.length-1];
                names.pop();
            }
        }
    }

    function removeMultipleNames(uint256[] calldata _names) external onlyOwner {
        for (uint256 i; i < _names.length; i++){
            removeName(_names[i]);
        }
    }

    function addAsset(address _asset) external onlyOwner{
        bool _found = false;
        for(uint256 i; i < assets.length; i++){
            if(assets[i] == _asset){
                _found = true;
            }
        }
        if(_found == false){
            assets.push(_asset);
        }
    }

    function removeAsset(address _asset) external onlyOwner{
    if(balance[_asset] == 0){
        for(uint256 i; i < assets.length; i++){
                if(assets[i] == _asset){
                    assets[i] = assets[assets.length-1];
                    assets.pop();
                }
            }  
        }
    }

    function countAssets() external view returns(uint256){
        return assets.length;
    }
}