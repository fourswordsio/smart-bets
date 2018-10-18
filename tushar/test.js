var Web3 = require('web3')
var tup = require('tuple')
web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

web3.eth.defaultAccount = web3.eth.accounts[0];
var DelayedBetContract = web3.eth.contract([
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
								"name": "apiUrl",
								"type": "string"
							},
							{
								"name": "keyPath",
								"type": "string[]"
							},
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
]);

var Test = DelayedBetContract.at('0xa93c6add4e1bbbb503d376127cb4376f642eb3c0');

var rawOracle = {
		apiUrl: "www.google.com",
		keyPath: ["123"],
		contractAddress: '0x7880648f57a04f4732de2357534501e02fe3551a',
		executionTime: 100
	}
//
// //var testOracle = Oracle(rawOracle);
// //Oracle(rawOracle);
//
var rawBet = {
		betId: "betId123",
		makerAddress: '0xe74ebb5c267cbc276637e39f3df469d894f08426',
		takerAddress: '0x233bc4cf7afb8780e43a276302063c5fd2360c8e',
		amount: 10,
		expirationTime: 500,
		Oracle: rawOracle
	}

//var betTest = new Bet(rawBet);
//Test.startBet({["betId123", '0xe74ebb5c267cbc276637e39f3df469d894f08426', '0x233bc4cf7afb8780e43a276302063c5fd2360c8e', 10, 500, ["www.google.com", ["123"], '0x7880648f57a04f4732de2357534501e02fe3551a', 100]], '0x233bc4cf7afb8780e43a276302063c5fd2360c8e'});
Test.startBet(rawBet,0,{});
// console.log(Bet.getInstructor());
//
// Coursetro.setInstructor('Orange', 44);
// console.log(Coursetro.getInstructor());

//console.log(Coursetro);
