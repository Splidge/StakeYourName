// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;


contract ENSSim {
    address public resolverAddress;
    address public bulkRegAddress;
    address public baseRegAddress;
    address public regContAddress;


    function ens() public view returns(address _ens){
        _ens = address(this);
    }
    function resolver(bytes32) public view returns(address){
        return resolverAddress;
    }
    function updateResolver(address _resolverAddress) public{
        resolverAddress = _resolverAddress;
    }
    function updateBulkReg(address _bulkRegAddress) public{
        bulkRegAddress = _bulkRegAddress;
    }
    function updateBaseReg(address _baseRegAddress) public{
        baseRegAddress = _baseRegAddress;
    }
    function updateRegController(address _regContAddress) public{
        regContAddress = _regContAddress;
    }
    
}
