// Fetch the NameManager contract data from the NameManager.json file
var NameManager = artifacts.require("NameManager");

// JavaScript export
module.exports = function(deployer) {
    // Deployer is the Truffle wrapper for deploying
    // contracts to the network

    // Deploy the contract to the network
    deployer.deploy(NameManager);
}