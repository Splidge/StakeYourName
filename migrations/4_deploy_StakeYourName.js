// Fetch the StakeYourName contract data from the StakeYourName.json file
var StakeYourName = artifacts.require("StakeYourName");

// JavaScript export
module.exports = function(deployer) {
    // Deployer is the Truffle wrapper for deploying
    // contracts to the network
    deployer.deploy(StakeYourName);
}