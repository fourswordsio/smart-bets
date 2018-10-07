const SmartBets = artifacts.require("./SmartBets.sol")

module.exports = function(deployer) {
	deployer.deploy(SmartBets);
};
