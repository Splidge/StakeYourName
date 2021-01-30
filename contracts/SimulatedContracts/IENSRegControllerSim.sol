// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IENSRegControllerSim {

    // Simulated functions
    function ens() external view returns(address);
    function renew(string calldata _id, uint256 _duration) external payable ;
    function nameExpires(uint256 _id) external view returns(uint256);

    // admin functions
    function withdraw() external ;
    function updateENS(address _ensAddress) external ;
    function updateName(uint256 _name, uint256 _expiry) external ;
    function day() external ;
    function month() external ;

}