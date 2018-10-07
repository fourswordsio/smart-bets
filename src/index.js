//var ethUtils = require('ethereumjs-util');



// $.getScript('./CreateBet.js', function()
// {
//     // script is now loaded and executed.
//     // put your dependent JS here.
//     const privateKey = ethUtil.sha3('cow'); // needs to be unique
//     console.log(privateKey);
// });

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

    console.log(usr1);

    var maker = document.getElementById("m_creator").value;
    var taker = document.getElementById("m_taker").value;
    var betAmount = document.getElementById("m_betAmount").value;
    var exp = document.getElementById("m_expiry").value;
    var betType = document.getElementById("m_betType").value;
    var settlementType = document.getElementById("m_settlementType").value;

    $.getJSON('Requester.json', function(data) {

        var requester = TruffleContract(data);
        requester.setProvider(web3Provider);
        console.log(requester);

<<<<<<< HEAD
=======
        var hash = web3.sha3("0x_I_am_maker_to_sign");

>>>>>>> 40176c35db8c2e5f530388c7cfaa4e085a9b650c
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

        if (taker != "") {
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

    // var jsonFile = "../build/contracts/Requester.json";
    // var parsed = JSON.parse(fs.readFileSync(jsonFile));

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
     console.log(RequestContract);
     var CONTRACT_ADDRESS = 0x0c93E38613aA69a4fCc3F2EfceCEF30342ea944d;
     var SmartBet = RequestContract.at(CONTRACT_ADDRESS);
     console.log(SmartBet);
     var contractInstance = RequestContract.new(
         {data: {
	"linkReferences": {},
	"object": "604c602c600b82828239805160001a60731460008114601c57601e565bfe5b5030600052607381538281f30073000000000000000000000000000000000000000030146080604052600080fd00a165627a7a7230582057f505e754c056dee90c5c570085d22661d9533808366f7359175c9067f4cb150029",
	"opcodes": "PUSH1 0x4C PUSH1 0x2C PUSH1 0xB DUP3 DUP3 DUP3 CODECOPY DUP1 MLOAD PUSH1 0x0 BYTE PUSH1 0x73 EQ PUSH1 0x0 DUP2 EQ PUSH1 0x1C JUMPI PUSH1 0x1E JUMP JUMPDEST INVALID JUMPDEST POP ADDRESS PUSH1 0x0 MSTORE PUSH1 0x73 DUP2 MSTORE8 DUP3 DUP2 RETURN STOP PUSH20 0x0 ADDRESS EQ PUSH1 0x80 PUSH1 0x40 MSTORE PUSH1 0x0 DUP1 REVERT STOP LOG1 PUSH6 0x627A7A723058 KECCAK256 JUMPI 0xf5 SDIV 0xe7 SLOAD 0xc0 JUMP 0xde 0xe9 0xc 0x5c JUMPI STOP DUP6 0xd2 0x26 PUSH2 0xD953 CODESIZE ADDMOD CALLDATASIZE PUSH16 0x7359175C9067F4CB1500290000000000 ",
	"sourceMap": "76:4196:0:-;;132:2:-1;166:7;155:9;146:7;137:37;252:7;246:14;243:1;238:23;232:4;229:33;270:1;265:20;;;;222:63;;265:20;274:9;222:63;;298:9;295:1;288:20;328:4;319:7;311:22;352:7;343;336:24"
},
          from: usr1,
          gas: 1000000},
          function(err, myContract){
       if(!err) {
          // NOTE: The callback will fire twice!
          // Once the contract has the transactionHash property set and once its deployed on an address.
           // e.g. check tx hash on the first call (transaction send)
          if(!myContract.address) {
              console.log("not my contract address");
              console.log(myContract.transactionHash); // The hash of the transaction, which deploys the contract

          // check address on the second call (contract deployed)
          } else {
              console.log("is my address");
              console.log(myContract.address); // the contract address
          }
           // Note that the returned "myContractReturned" === "myContract",
          // so the returned "myContractReturned" object will also get the address set.
       }
 });


 web3.eth.sendTransaction({from: maker,to: taker, value:web3.toWei(0.05, "ether")},
 function(error, result){
    if(!error)
        console.log(JSON.stringify(result));
    else
        console.error(error);
});


    // create bet
    // lastEthPrice("", maker, exp - now);

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
