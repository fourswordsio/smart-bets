var Contract = artifacts.require('Requester');
console.log(Contract.abi)
contract('Contract', accounts => {
    Contract.deployed().then(instance => {

        console.log(instance.abi);

    });
});
