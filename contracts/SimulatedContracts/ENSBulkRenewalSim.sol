// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/SimulatedContracts/IENSBaseRegistrarSim.sol";

contract BulkRenewalSim is Ownable {
    address ensAddress = address(0);
    address ensBaseRegistrar = address(0);

    constructor(address _ensAddress, address _baseRegistrar){
        ensAddress = _ensAddress;
        ensBaseRegistrar = _baseRegistrar;
    }
    // Simulated functions
    function ens() public view returns(address){
        return (ensAddress);
    }
    function renewAll(string[] calldata _id, uint256 _duration) public payable {
        require(msg.value > 0);
        IBaseRegistrarSim _baseReg = IBaseRegistrarSim(ensBaseRegistrar);
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
    function updateBaseRegistrar(address _ensBaseRegAddress) public {
        ensBaseRegistrar = _ensBaseRegAddress;
    }
}