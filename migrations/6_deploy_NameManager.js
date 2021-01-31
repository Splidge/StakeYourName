// Fetch the investment contract data from the investment.json file
var NameManager = artifacts.require("NameManager");

// JavaScript export
module.exports = function(deployer) {
    // Deployer is the Truffle wrapper for deploying
    // contracts to the network
    console.log('deploying to:');
    console.log(deployer.network);
    // Deploy the contract to the network and pass in the network ID if possible
    if (deployer.network == 'kovan' || deployer.network == 'kovan-fork'){
        deployer.deploy(NameManager,42);
    } else if (deployer.network == 'live'){
        deployer.deploy(NameManager,1);
    } else if (deployer.network == 'ropsten'){
        deployer.deploy(NameManager,3);
    } else if (deployer.network == 'development'){
        deployer.deploy(NameManager,1337);
    } else {
        console.log('network not found, deploying anyway')   
        deployer.deploy(NameManager, 0);
    }
}