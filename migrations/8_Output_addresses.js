// Fetch the investment contract data from the investment.json file
var InvestmentManager = artifacts.require("InvestmentManager");
var NameManager = artifacts.require("NameManager");
var ExchangeManager = artifacts.require("ExchangeManager");
var StakeYourName = artifacts.require("StakeYourName");
var ENSSim = artifacts.require("ENSSim");
var ENSBaseRegistrarSim = artifacts.require("ENSBaseRegistrarSim");
var ENSBulkRenewalSim = artifacts.require("ENSBulkRenewalSim");
var ENSResolverSim = artifacts.require("ENSResolverSim");
var ENSRegControllerSim = artifacts.require("ENSRegControllerSim");
var oneSplitSim = artifacts.require("oneSplitSim");
var UserVault = artifacts.require("UserVault");

// JavaScript export
module.exports = function(deployer) {
    // Deployer is the Truffle wrapper for deploying
    // contracts to the network
    //var myAddresses = "['".concat(NameManager.address).concat("','").concat(InvestmentManager).concat("']");

    console.log({
        StakeYourName: StakeYourName.address,
        NameManager: NameManager.address,
        ExchangeManager: ExchangeManager.address,
        InvestmentManager: InvestmentManager.address,
        UserVault: UserVault.address,
        oneSplitSim: oneSplitSim.address,
        ENSSim: ENSSim.address,
    });

}