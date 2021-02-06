// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./IENSSim.sol";

contract ENSResolverSim {
    address alice = 0x54534C4FB48f541F44F2097B8DA24A1c4Fa61aB2;
    address bob = 0x8Ae6cCBdb5F1Dd14A5737dfA65489eDD50E188ed;
    address charlie = 0x5585aa20A6790e23D7A03f4f20A0E73C19dF2FF4;
    address splidge = 0x13eBa327774c6Feac18f3c2793364d05275AFEB6;

    bytes32 aliceHash = 0x787192fc5378cc32aa956ddfdedbf26b24e8d78e40109add0eea2c1a012c3dec;
    bytes32 bobHash = 0xbe11069ec59144113f438b6ef59dd30497769fc2dce8e2b52e3ae71ac18e47c9;
    bytes32 charlieHash = 0xab5941f17af267ac13cc2361e95a3d83ce347f05d5192baabe0cc7cc26b81a9c;
    bytes32 splidgeHash = 0x6332e6cb2f726edb4a48f583318dedd5ec9ddc8622b76b1d6d44748169fffd51;

    address ens;
    constructor(address _ens){
        ens = _ens;
        IENSSim ensSim = IENSSim(ens);
        ensSim.updateResolver(address(this));
    }

    function addr(bytes32 _hash) public view returns(address){
        if (_hash == aliceHash){return alice;}
        if (_hash == bobHash){return bob;}
        if (_hash == charlieHash){return charlie;}
        if (_hash == splidgeHash){return splidge;}
        return address(0);
    }
}