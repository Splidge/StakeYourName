// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IENSSim {
    function ens() external view returns(address _ens);
    function resolver(bytes32) external view returns(address);
    function updateResolver(address _resolverAddress) external;
    function updateBulkReg(address) external;
    function updateBaseReg(address) external;
    function updateRegController(address) external;
    function resolverAddress() external view returns(address);
    function bulkRegAddress() external view returns(address);
    function baseRegAddress() external view returns(address);
    function regContAddress() external view returns(address);
}
