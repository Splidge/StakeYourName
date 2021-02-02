// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IENSSim.sol";
import "./IENSRegControllerSim.sol";

contract ENSBaseRegistrarSim is Ownable {
    address ensAddress = address(0);
    address regContAddress = address(0);
    uint256 renewPrice = 118496123;
    uint256 balance = 0;
    
    mapping (uint256 => uint256) expiry;
    uint256[] names;

    constructor(address _ensAddress, address _regCont){
        ensAddress = _ensAddress;
        IENSSim ensSim = IENSSim(_ensAddress);
        regContAddress = _regCont;
        ensSim.updateBaseReg(address(this));
    }

    // Simulated functions
    function ens() public view returns(address){
        return (ensAddress);
    }
    function nameExpires(uint256 _id) public view returns(uint256){
        IENSRegControllerSim _ensRegCont = IENSRegControllerSim(regContAddress);
        return (_ensRegCont.expires(_id));
    }
    function updateRegCont(address _regCont) public {
        regContAddress = _regCont;
    }

    // admin functions
    function withdraw() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }
    function updateENS(address _ensAddress) public {
        ensAddress = _ensAddress;
    }
    function retrieveETH() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

}