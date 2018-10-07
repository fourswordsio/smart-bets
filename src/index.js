

function init() {
  console.log( "init!" );
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

    var maker = document.getElementById("creator").value;
    var taker = document.getElementById("taker").value;
    var betAmount = document.getElementById("betAmount").value;
    var exp = document.getElementById("expiry").value;
    var betType = document.getElementById("betType").value;
    var settlementType = document.getElementById("settlementType").value;

    $.getJSON('Requester.json', function(data) {

        var requester = TruffleContract(data);
        requester.setProvider(web3Provider);
        console.log(requester);
/*
        requester.deployed().then(function(instance) {
          return instance.???????({from: accounts[0]});
        }).then(function(result) {
          console.log(result)
          ???????();
        }).catch(function(err) {
          console.log(err.message);
        });*/

        //var bet = requester.at(0x877d8ec22382748366e1b2665ee78a60d891c87c56c5be2dab555716bdc6915f);
    });
}

//var jsonFile = "../build/contracts/Requester.json";
//var parsed = JSON.parse(fs.readFileSync(jsonFile));
//var abi = parsed.abi

// var SmartBetContract = web3.eth.contract(abi);
//
// var SmartBet = SmartBetContract.at('PASTE CONTRACT ADDRESS HERE');
// console.log(SmartBet);
//

// var jsonFile = "../build/contracts/Requester.json";
// var parsed = JSON.parse(fs.readFileSync(jsonFile));
/*
var abi = [ { constant: false,
    inputs: [],
    name: 'renounceOwnership',
    outputs: [],
    payable: false,
    stateMutability: 'nonpayable',
    type: 'function' },
  { constant: true,
    inputs: [],
    name: 'owner',
    outputs: [ [Object] ],
    payable: false,
    stateMutability: 'view',
    type: 'function' },
  { constant: false,
    inputs: [ [Object] ],
    name: 'transferOwnership',
    outputs: [],
    payable: false,
    stateMutability: 'nonpayable',
    type: 'function' },
  { inputs: [],
    payable: false,
    stateMutability: 'nonpayable',
    type: 'constructor' },
  { anonymous: false,
    inputs: [ [Object], [Object] ],
    name: 'RequestFulfilled',
    type: 'event' },
  { anonymous: false,
    inputs: [ [Object] ],
    name: 'OwnershipRenounced',
    type: 'event' },
  { anonymous: false,
    inputs: [ [Object], [Object] ],
    name: 'OwnershipTransferred',
    type: 'event' },
  { anonymous: false,
    inputs: [ [Object] ],
    name: 'ChainlinkRequested',
    type: 'event' },
  { anonymous: false,
    inputs: [ [Object] ],
    name: 'ChainlinkFulfilled',
    type: 'event' },
  { anonymous: false,
    inputs: [ [Object] ],
    name: 'ChainlinkCancelled',
    type: 'event' },
  { constant: false,
    inputs: [ [Object], [Object], [Object] ],
    name: 'lastEthPrice',
    outputs: [ [Object] ],
    payable: false,
    stateMutability: 'nonpayable',
    type: 'function' } ]

 var SmartBetContract = web3.eth.contract(abi);
 console.log(SmartBetContract);
 var SmartBet = SmartBetContract.at(0x0c93E38613aA69a4fCc3F2EfceCEF30342ea944d);
 console.log(SmartBet);*/

 SmartBet.methods["lastEthPrice"]
// Coursetro.getInstructor(function(error, result){
//  if(!error)
//      {
//          $("#instructor").html(result[0]+' ('+result[1]+' years old)');
//          console.log(result);
//      }
//  else
//      console.error(error);
// });
//
// $("#button").click(function() {
//  Coursetro.setInstructor($("#name").val(), $("#age").val());
// });
//

// When the page loads, this will call the init() function
//$( document ).ready(function() {
//    init();
//    console.log( "ready!" );
//});
