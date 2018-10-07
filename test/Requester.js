let Contract = artifacts.require('./Requester.sol');

contract('Contract', accounts => {
    Contract.deployed().then(instance => {

        console.log(instance.abi);

    });
});
