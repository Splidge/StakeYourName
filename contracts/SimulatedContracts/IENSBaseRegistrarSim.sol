// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IENSBaseRegistrarSim {
  
    // Simulated functions
    function ens() external view returns(address);
    function nameExpires(uint256 _id) external view returns(uint256);
    // admin functions
    function withdraw() external;
    function updateENS(address _ensAddress) external;
    function retrieveETH() external;
    function updateRegCont(address _regCont) external;
}