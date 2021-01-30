// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/SimulatedContracts/IENSRegControllerSim.sol";
import "contracts/SimulatedContracts/IENSSim.sol";

contract ENSBulkRenewalSim is Ownable {
    address ensAddress;
    address ensRegCont;

    constructor(address _ensAddress, address _RegCont){
        ensAddress = _ensAddress;
        ensRegCont = _RegCont;
        IENSSim ensSim = IENSSim(_ensAddress);
        ensSim.updateBulkReg(address(this));
    }
    // Simulated functions
    function ens() public view returns(address){
        return (ensAddress);
    }
    function renewAll(string[] calldata _id, uint256 _duration) public payable {
        require(msg.value > 0);
        IENSRegControllerSim _baseReg = IENSRegControllerSim(ensRegCont);
        for(uint256 i; i < _id.length; i++){
            _baseReg.renew{value:(address(this).balance)}(_id[i], _duration);
        }
        msg.sender.transfer(address(this).balance);
    }
    function supportsInterface(bytes4) public pure returns(bool){
        return (true);
    }


    // admin functions
    function withdraw() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }
    function updateENS(address _ensAddress) public {
        ensAddress = _ensAddress;
    }
}