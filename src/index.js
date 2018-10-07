


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

var RequestContract = web3.eth.contract(abi);

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

    var maker = document.getElementById("m_creator").value;
    var taker = document.getElementById("m_taker").value;
    var betAmount = document.getElementById("m_betAmount").value;
    var exp = document.getElementById("m_expiry").value;
    var betType = document.getElementById("m_betType").value;
    var settlementType = document.getElementById("m_settlementType").value;
    var bytecode;
    $.getJSON('Requester.json', function(data) {

        bytecode = data["bytecode"];
        var requester = TruffleContract(data);

        requester.setProvider(web3Provider);
        var hash = web3.sha3("0x_I_am_maker_to_sign");
/*
        const makerSig = new Promise(function(resolve, reject) {
            web3.personal.sign(hash, maker, function(err, res) {
                if (error) {
                    reject(err);
                } else {
                    resolve(res);
                }
            })
        });
        console.log(makerSig);

        const takeSig = new Promise(function(resolve, reject) {
            web3.personal.sign(hash, taker, function(err, res) {
                if (err) {
                    reject(err);
                } else {
                    resolve(res);
                }
            })
        });
        console.log(takeSig);
*/

        const makerSig =  web3.personal.sign(hash, maker, function(err, res) {
                            if (err) console.error(err);
                            console.log(res);
                        });
        console.log(makerSig);

        if (taker !== 'undefined') {
            hash = web3.sha3("0x_I_am_taker_to_sign");
            const takerSig =  web3.personal.sign(hash, taker, function(err, res) {
                                if (err) console.error(err);
                                console.log(res);
                            });
            console.log(takerSig);
        }


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

     console.log("RequestContract", RequestContract);

     // console.log(SmartBet);
     // var contractInstance = RequestContract.new(
     //     {data: bytecode,
     //      from: usr1,
     //      gas: 1000000},
     //      function(err, myContract){
     //   if(!err) {
     //       console.log("myContract", myContract);
     //
     //       var CONTRACT_ADDRESS = 0x0c93E38613aA69a4fCc3F2EfceCEF30342ea944d;
     //       var SmartBet = RequestContract.at(CONTRACT_ADDRESS);
     //      // NOTE: The callback will fire twice!
     //      // Once the contract has the transactionHash property set and once its deployed on an address.
     //       // e.g. check tx hash on the first call (transaction send)
     //      if(!myContract.address) {
     //          console.log("not my contract address");
     //          console.log(myContract.transactionHash); // The hash of the transaction, which deploys the contract
     //
     //      // check address on the second call (contract deployed)
     //      } else {
     //          console.log("is my address");
     //          console.log(myContract.address); // the contract address
     //      }
     //       // Note that the returned "myContractReturned" === "myContract",
     //      // so the returned "myContractReturned" object will also get the address set.
     //   }
} // init betting

var CONTRACT_ADDRESS = 0xE77B5def34679066d1173766c84B0006c9A5DC20;
function takerSignAndSend(){
    var betId = document.getElementById("t_betId").value;
    var taker = document.getElementById("t_taker").value;
    var betAmount = document.getElementById("t_betAmount").value;
    var exp = document.getElementById("t_expiry").value;
    var betType = document.getElementById("t_betType").value;
    var settlementType = document.getElementById("t_settlementType").value;

    // taker sign and send
    hash = web3.sha3("0x_I_am_taker_to_sign");
    const takerSig =  web3.personal.sign(hash, taker, function(err, res) {
                        if (err) console.error(err);
                        console.log(res);
                        SendTransaction(taker, CONTRACT_ADDRESS, betAmount);
                    });
    console.log(takerSig);
}

function SendTransaction(maker, CONTRACT_ADDRESS, etherAmount){
   web3.eth.sendTransaction({from: maker,to: taker, value:web3.toWei(etherAmount, "ether")},
   function(error, result){
      if(!error)
          console.log(JSON.stringify(result));
      else
          console.error(error);
  });
}
 // SmartBet.methods["lastEthPrice"]
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
