// Fetch the ExchangeManager contract data from the ExchangeManager.json file
var ExchangeManager = artifacts.require("ExchangeManager");

// JavaScript export
module.exports = function(deployer) {
    // Deployer is the Truffle wrapper for deploying
    // contracts to the network
    deployer.deploy(ExchangeManager);
}