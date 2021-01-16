// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "interfaces/ENS.sol";
import "interfaces/BaseRegistrar.sol";

// @author Daniel Chilvers
contract StakeYourName is Ownable {
    address immutable ensRegistry = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;
    address immutable BaseRegistrarAddress = 0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85;
    ENS ens;
    BaseRegistrar ensReg;

    function getNameExpiry(uint256 _name) public view returns(uint256){
        return ensReg.nameExpires(_name);
    }

    //Stuff to help out with ENS
    function convertBytesToUint(bytes32 _bytes) public pure returns(uint256){
        uint256 _uint = uint256(_bytes);
        return (_uint);
    }
    function convertUintToBytes(uint256 _uint) public pure returns(bytes32){
        bytes32 _bytes = bytes32(_uint);
        return (_bytes);
    }
    function computeNamehash(string calldata _name) public pure returns (bytes32 namehash) {
        namehash = 0x0000000000000000000000000000000000000000000000000000000000000000;
        namehash = keccak256(abi.encodePacked(namehash, keccak256(abi.encodePacked('eth'))));
        namehash = keccak256(abi.encodePacked(namehash, keccak256(abi.encodePacked(_name))));
    }
    function computeLabelhash(string calldata _name) public pure returns (bytes32 namehash) {
        namehash = keccak256(abi.encodePacked(_name));
    }


}
