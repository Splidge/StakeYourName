// Fetch the NameManager contract data from the NameManager.json file
var InvestementManager = artifacts.require("InvestementManager");

// JavaScript export
module.exports = function(deployer) {
    // Deployer is the Truffle wrapper for deploying
    // contracts to the network

    // Deploy the contract to the network and pass in the network ID if possible
    if (network == "kovan"){
        deployer.deploy(InvestmentManager,"42");
    } else if (network == "live"){
        deployer.deploy(InvestmentManager,"1");
    } else if (network == "ropsten"){
        deployer.deploy(InvestmentManager,"3");
    } else if (network == "development"){
        deployer.deploy(InvestmentManager,"1337");
    } else {
        deployer.deploy(InvestmentManager);
    }
}