if (typeof web3 !== 'undefined') {
    web3 = new Web3(web3.currentProvider);
} else {
    // set the provider you want from Web3.providers
    web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
}

web3.eth.defaultAccount = web3.eth.accounts[0];

var SmartBetContract = web3.eth.contract(YOUR ABI);

var SmartBet = SmartBetContract.at('PASTE CONTRACT ADDRESS HERE');
console.log(SmartBet);

Coursetro.getInstructor(function(error, result){
 if(!error)
     {
         $("#instructor").html(result[0]+' ('+result[1]+' years old)');
         console.log(result);
     }
 else
     console.error(error);
});

$("#button").click(function() {
 Coursetro.setInstructor($("#name").val(), $("#age").val());
});
