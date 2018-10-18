pragma solidity ^0.4.24;

import "./SmartBet.sol";
import "./Requester.sol"; // TODO: Remove this dependency

import "./ChainlinkContracts.sol"; // Pull in Ownable
pragma experimental ABIEncoderV2;

contract delayedPriceBetConsumer is SmartBet, Ownable {
  // Force all consumers to use SmartBets oracle address?
  address constant ROPSTEN_ORACLE_ADDRESS = 0x261a3f70acdc85cfc2ffc8bade43b1d42bf75d69;

  // Store bets
  uint256 public roll;
  uint256 public lastRollTimestamp;

  mapping(bytes32 => bytes32) public liveBets; // Convert into live bets?

  Requester internal requester; // TODO: Replace this with address and abi calls
  address internal oracle;
  LinkToken internal link;

  constructor(address _requester) public Ownable() {
    oracle = ROPSTEN_ORACLE_ADDRESS;
    requester = Requester(_requester);
  }

  event RequestFulfilled(
    bytes32 requestId,
    uint256 price
  );

  function startBet(Bet memory _bet, address _takerAddress, bytes _signature) public {
    assertStartableBet(_bet, _takerAddress, _signature);
    requester.randomNumberBet(
      [1,100], // range
      hash(_bet),
      "fulfillLastPrice(bytes32,uint256)", 
      address(this)
    );
  }

  function updateRequestId(bytes32 _requestId, bytes32 _betId) external onlyRequester {
    liveBets[_requestId] = _betId;
  }

  function fulfillLastPrice(bytes32 _requestId, uint256 _randomNumber)
    public
    checkChainlinkFulfillment(_requestId)
  {
    emit RequestFulfilled(_requestId, _randomNumber);
    lastRollTimestamp = now;
    roll = _price;
  }

  function withdrawLink() public onlyOwner {
    require(link.transfer(owner, link.balanceOf(address(this))));
  }

  modifier checkChainlinkFulfillment(bytes32 _requestId) {
    require(msg.sender == oracle && liveBets[_requestId] != 0, "Source must be the oracle of the request");
    _;
    delete liveBets[_requestId]; // TODO: bet settlement
  }

  modifier onlyRequester() {
    require(msg.sender == address(requester), "Only the requester can run this function");
    _;
  }
}
