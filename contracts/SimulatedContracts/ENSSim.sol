// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;


contract ENSSim {
    address resolverAddress;
    constructor(address _resolver){
        resolverAddress = _resolver;
    }
    function ens() public view returns(address _ens){
        _ens = address(this);
    }
    function resolver(bytes32) public view returns(address){
        return resolverAddress;
    }
    function updateResolver(address _resolverAddress) public{
        resolverAddress = _resolverAddress;
    }
}
