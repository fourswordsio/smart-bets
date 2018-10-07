


var abi = [
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"name": "previousOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnershipTransferred",
		"type": "event"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_requestId",
				"type": "bytes32"
			},
			{
				"name": "_price",
				"type": "uint256"
			}
		],
		"name": "fulfillLastPrice",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"name": "previousOwner",
				"type": "address"
			}
		],
		"name": "OwnershipRenounced",
		"type": "event"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "renounceOwnership",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "requestId",
				"type": "bytes32"
			},
			{
				"indexed": false,
				"name": "price",
				"type": "uint256"
			}
		],
		"name": "RequestFulfilled",
		"type": "event"
	},
	{
		"constant": false,
		"inputs": [
			{
				"components": [
					{
						"name": "betId",
						"type": "string"
					},
					{
						"name": "makerAddress",
						"type": "address"
					},
					{
						"name": "takerAddress",
						"type": "address"
					},
					{
						"name": "amount",
						"type": "uint32"
					},
					{
						"name": "expirationTime",
						"type": "uint256"
					},
					{
						"components": [
							{
								"name": "contractAddress",
								"type": "address"
							},
							{
								"name": "executionTime",
								"type": "uint32"
							}
						],
						"name": "oracleSpec",
						"type": "tuple"
					}
				],
				"name": "_bet",
				"type": "tuple"
			},
			{
				"name": "_takerAddress",
				"type": "address"
			}
		],
		"name": "startBet",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_newOwner",
				"type": "address"
			}
		],
		"name": "transferOwnership",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"name": "_requester",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_requestId",
				"type": "bytes32"
			},
			{
				"name": "_betId",
				"type": "bytes32"
			}
		],
		"name": "updateRequestId",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "withdrawLink",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "lastPrice",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "lastPriceTimestamp",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "bytes32"
			}
		],
		"name": "liveBets",
		"outputs": [
			{
				"name": "",
				"type": "bytes32"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	}
];
var RequestContract = web3.eth.contract(abi);
var contractInstance = RequestContract.at("0x7d72a42f287c1d00cc6865897e5d07d03922b8d3");

function init() {
  console.log( "init!" );
  // We init web3 so we have access to the blockchain
  initWeb3();
}

function initWeb3() {
  if (typeof web3 !== 'undefined' && typeof web3.currentProvider !== 'undefined') {
    web3Provider = web3.currentProvider;
    web3 = new Web3(web3Provider);
    console.log("real web3", web3Provider);
  } else {
  	// set the provider you want from Web3.providers
    web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
    console.log("localhost web3");
    //console.error('No web3 provider found. Please install Metamask on your browser.');
    //alert('No web3 provider found. Please install Metamask on your browser.');
  }

  // init the main func
  initBetting();
}

bets = []

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
        var hash = web3.sha3("0x_I_am_maker_to_sign" + bets.length.toString());
        // web3.eth.accounts.privateKeyToAccount(hash);

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
                            if (err) console.error("makersig err", err);
                            else {
                                console.log("makerSig res", res);

                            //     "inputs": [
                        	// 		{
                        	// 			"components": [
                        	// 				{
                        	// 					"name": "betId",
                        	// 					"type": "string"
                        	// 				},
                        	// 				{
                        	// 					"name": "makerAddress",
                        	// 					"type": "address"
                        	// 				},
                        	// 				{
                        	// 					"name": "takerAddress",
                        	// 					"type": "address"
                        	// 				},
                        	// 				{
                        	// 					"name": "amount",
                        	// 					"type": "uint32"
                        	// 				},
                        	// 				{
                        	// 					"name": "expirationTime",
                        	// 					"type": "uint256"
                        	// 				},
                        	// 				{
                        	// 					"components": [
                        	// 						{
                        	// 							"name": "contractAddress",
                        	// 							"type": "address"
                        	// 						},
                        	// 						{
                        	// 							"name": "executionTime",
                        	// 							"type": "uint32"
                        	// 						}
                        	// 					],
                        	// 					"name": "oracleSpec",
                        	// 					"type": "tuple"
                        	// 				}
                        	// 			],
                        	// 			"name": "_bet",
                        	// 			"type": "tuple"
                        	// 		},
                        	// 		{
                        	// 			"name": "_takerAddress",
                        	// 			"type": "address"
                        	// 		}
                        	// 	],
                        	// 	"name": "startBet",
                        	// 	"outputs": [],
                        	// 	"payable": false,
                        	// 	"stateMutability": "nonpayable",
                        	// 	"type": "function"
                        	// },

                                var newBet = createBet(bets.length.toString(),
                                                        maker,
                                                        "0x000",
                                                        betAmount,
                                                        exp,
                                                        "0x7d72a42f287c1d00cc6865897e5d07d03922b8d3",
                                                        1);
                                console.log("newBet creating", newBet);
                                var id = bets.push(newBet);
                                console.log("bet id created", id);
                            }
                        });

        // if (taker !== "") {
        //     console.log(taker);
        //     hash = web3.sha3("0x_I_am_taker_to_sign");
        //     const takerSig =  web3.personal.sign(hash, taker, function(err, res) {
        //                         if (err) console.error("takerSig err", err);
        //                         console.log("taker sig res", res);
        //                     });
        //     console.log("taker sig", takerSig);
        // }


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

var CONTRACT_ADDRESS = "0x13661656a4a8ce881cc091b94c952a0378d7e413";
function takerSignAndSend(){
    var betId = document.getElementById("t_betId").value;
    var taker = document.getElementById("t_taker").value;
    var betAmount = document.getElementById("t_betAmount").value;
    var exp = document.getElementById("t_expiry").value;
    var betType = document.getElementById("t_betType").value;
    var settlementType = document.getElementById("t_settlementType").value;

    // // taker sign and send
    // hash = web3.sha3("0x_I_am_taker_to_sign");
    // const takerSig =  web3.personal.sign(hash, taker, function(err, res) {
    //                     if (err) console.error("sig err", err);
    //                     console.log("sig res", res);
    //                     SendTransaction(taker, CONTRACT_ADDRESS, betAmount);
    //                 });

    console.log("betId", betId);
    console.log("bets", bets);
    var currentBet = bets[betId];
    //
    // var newBet = createBet(betId,
    //                         bets[betId]["makerAddress"],
    //                         taker,
    //                         betAmount,
    //                         exp,
    //                         "0x7d72a42f287c1d00cc6865897e5d07d03922b8d3",
    //                         111111111111);

    // check if bet is ready to go

    // bet object
    console.log("currentBet", currentBet);
    contractInstance.startBet.sendTransaction(currentBet, taker, bets[betId][1]);
    // var getData = Requester.startBet.getData(currentBet, taker);
    // web3.eth.sendTransaction({to:CONTRACT_ADDRESS, from: taker, data:getData});
// // suppose you want to call a function named myFunction of myContract
// var getData = myContract.myFunction.getData(function parameters);
// //finally paas this data parameter to send Transaction
// web3.eth.sendTransaction({to:Contractaddress, from:Accountaddress, data: getData});


    // SendTransaction(taker, CONTRACT_ADDRESS, betAmount);
}

// bet = {
//     { betId: "BET_ID_STRING"},
//     { makerAddress: "address" }, //from metamask
//     { takerAddress: "address"}, // empty or full
//     { amount : 1 },
//     { expirationTime : 11010101}, //"unix time stamp"
//     { oracleSpec :
//         Oracle :{
//             {contractAddress : "Address",},
//             {executionTime : 110101010} //unix time stamp
//         }
//     }
// }
// Builds the bet object used for signing - see above
function createBet(
                betId,
                makerAddress,
                takerAddress,
                amount,
                expirationTime,
                oracleContractAddress,
                oracleExecutionTime)
{
    bet = {};
    bet["betId"] = betId;
    bet["makerAddress"] = makerAddress;
    bet["takerAddress"] = takerAddress;
    bet["amount"] = amount;
    bet["expirationTime"] = expirationTime;
    var oracle = {};
    oracle["contractAddress"] = oracleContractAddress;
    oracle["executionTime"] = oracleExecutionTime;
    bet["oracleSpec"] = oracle;
    return bet;
}

function SendTransaction(from, CONTRACT_ADDRESS, etherAmount){
    console.log("isAddress:", web3.isAddress(CONTRACT_ADDRESS));

   web3.eth.sendTransaction({from: from,to: CONTRACT_ADDRESS, value:web3.toWei(etherAmount, "ether")},
   function(error, result){
      if(!error)
          console.log("no error:",JSON.stringify(result));
      else
          console.log("caught error", error);
    console.log("result", result);
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
