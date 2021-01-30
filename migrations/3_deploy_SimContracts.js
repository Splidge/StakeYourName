// Fetch the investment contract data from the investment.json file
var ENSSim = artifacts.require("ENSSim");
var ENSBaseRegistrarSim = artifacts.require("ENSBaseRegistrarSim");
var ENSBulkRenewalSim = artifacts.require("ENSBulkRenewalSim");
var ENSResolverSim = artifacts.require("ENSResolverSim");
var oneSplitSim = artifacts.require("oneSplitSim");

// JavaScript export
module.exports = function(deployer) {
    // Deployer is the Truffle wrapper for deploying
    // contracts to the network
    console.log('deploying to:');
    console.log(deployer.network);
    // Deploy the contract to the network and pass in the network ID if possible
    if (deployer.network == 'kovan' || deployer.network == 'kovan-fork'){
        deployer.deploy(oneSplitSim);
        deployer.deploy(ENSSim);
        deployer.deploy(ENSBaseRegistrarSim, ENSSim.address);
        deployer.deploy(ENSBulkRenewalSim, ENSSim.address, ENSBaseRegistrarSim.address);
        deployer.deploy(ENSResolverSim, ENSSim.address);
        
        
        
    } 
}