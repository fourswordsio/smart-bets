const SmartBets = artifacts.require("./SmartBet.sol")

module.exports = function(deployer) {
	deployer.deploy(SmartBets);
};
