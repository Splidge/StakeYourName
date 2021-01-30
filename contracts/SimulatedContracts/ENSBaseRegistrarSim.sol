// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/SimulatedContracts/IENSSim.sol";

contract ENSBaseRegistrarSim is Ownable {
    address ensAddress = address(0);
    uint256 renewPrice = 118496123;
    uint256 balance = 0;
    
    mapping (uint256 => uint256) expiry;
    uint256[] names;

    constructor(address _ensAddress){
        ensAddress = _ensAddress;
        IENSSim ensSim = IENSSim(_ensAddress);
        ensSim.updateBaseReg(address(this));
    }

    // Simulated functions
    function ens() public view returns(address){
        return (ensAddress);
    }
    function nameExpires(uint256 _id) public view returns(uint256){
        return (expiry[_id]);
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