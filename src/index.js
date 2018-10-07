
function init() {
  // We init web3 so we have access to the blockchain
  initWeb3();
}


function initWeb3() {
  if (typeof web3 !== 'undefined' && typeof web3.currentProvider !== 'undefined') {
    web3Provider = web3.currentProvider;
    web3 = new Web3(web3Provider);
  } else {
  	// set the provider you want from Web3.providers
    web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

    //console.error('No web3 provider found. Please install Metamask on your browser.');
    //alert('No web3 provider found. Please install Metamask on your browser.');
  }

  // init the main func
  initBetting();
}


function initBetting() {

	var usr1 = web3.eth.accounts[0]; // TODO: Let user pick maker/taker from the list of accounts?
	var usr2 = web3.eth.accounts[1]; // TODO: Let user pick maker/taker from the list of accounts?


}


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


// When the page loads, this will call the init() function
$(function() {
  $(window).load(function() {
    init();
  });
});
