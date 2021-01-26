// Fetch the UserVault contract data from the UserVault.json file
var UserVault = artifacts.require("UserVault");

// JavaScript export
module.exports = function(deployer) {
    // Deployer is the Truffle wrapper for deploying
    // contracts to the network

    // Deploy the contract to the network
    deployer.deploy(UserVault);
}