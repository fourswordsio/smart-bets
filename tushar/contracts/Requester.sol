pragma solidity ^0.4.24;

import "./ChainlinkContracts.sol";
pragma experimental ABIEncoderV2;

contract Requester is Chainlinked, Ownable {

  address constant ROPSTEN_LINK_ADDRESS = 0x20fE562d797A42Dcb3399062AE9546cd06f63280;
  address constant ROPSTEN_ORACLE_ADDRESS = 0x261a3f70acdc85cfc2ffc8bade43b1d42bf75d69; // this one has our specID

  // All validated job specs
  // What we can do is have a list of accepted SPEC_IDs in this contract.
  // We can remove, add, update spec IDs.
  // Spec IDs are passed in via consumer contracts.
  // Multiple spec IDs/consuming contracts can be used per request function here
  bytes32 constant DELAYED_PRICE_ID = bytes32("dc56d871480a4787bb076917ceda0699");
  bytes32 constant DICE_ROLL_ID = bytes32(""); 

  //bytes32[] public VALID_SPEC_IDS = []

  IConsumer internal con;

  event RequestFulfilled(
    bytes32 indexed requestId,
    uint256 indexed price
  );

  constructor() Ownable() public {
    setLinkToken(ROPSTEN_LINK_ADDRESS);
    setOracle(ROPSTEN_ORACLE_ADDRESS); // Will move setOracle to happen per bet
  }

  function Bet(string _apiUrl, string[] _keyPath, bytes32 betId, bytes32 _specId, string _callback, address _caller)
    public
    // With this generic bet, we should move validation to consumer
    //validSpec(_specId)
  {
    ChainlinkLib.Run memory run = newRun(DICE_ROLL_ID, _caller, _callback);

    run.add("url", _apiUrl);
    run.addStringArray("path", _keyPath);
    // Can run any Bet
    con = IConsumer(_caller);
    //con.updateRequestId(chainlinkRequest(run, LINK(1)), betId);
  }

  function extBet(int32[] range, bytes32 betId, bytes32 _specId, string _callback, address _caller)
    public
    // With this generic bet, we should move validation to consumer
    //validSpec(_specId)
  {
    ChainlinkLib.Run memory run = newRun(DICE_ROLL_ID, _caller, _callback);
    // Can run any Bet
    con = IConsumer(_caller);
    //con.updateRequestId(chainlinkRequest(run, LINK(1)), betId);
  }

  function delayedBet(
    string _apiUrl, 
    string[] _keyPath, 
    uint256 _delay, 
    //bytes32 betId, 
    string _callback, 
    address _caller
  )
    public
    //validSpec(_specId)
    validExecutionTime(_delay) // Should bet validation happen here, or at consumer level
    returns(bytes32)
  {
    ChainlinkLib.Run memory run = newRun(DELAYED_PRICE_ID, _caller, _callback);

    run.add("url", _apiUrl);
    run.addStringArray("path", _keyPath);
    // If we parameterize/add to specID, we could use a generic delayed bet
    //run.addInt("times", 100); // Should this be parameterized? Need to think more about this
    run.addInt("times", 100);
    //run.addUint("until", now + _delay); 
    run.addUint("until", now + 20); 
    con = IConsumer(_caller);
    //con.updateRequestId(chainlinkRequest(run, LINK(1)), betId);
    con.updateRequestId(chainlinkRequest(run, LINK(1)));
  }

  function delayedExtBet(string[] _keyPath, uint256 _delay, bytes32 betId, bytes32 _specId, string _callback, address _caller)
    public
    //validSpec(_specId)
    validExecutionTime(_delay) // Should bet validation happen here, or at consumer level, or both?
    returns(bytes32)
  {
    ChainlinkLib.Run memory run = newRun(DELAYED_PRICE_ID, _caller, _callback);

    run.addStringArray("copyPath", _keyPath);
    run.addUint("until", now + _delay); 
    con = IConsumer(_caller);
    //con.updateRequestId(chainlinkRequest(run, LINK(1)), betId);
  }

  // What about bets that require specific arguments?
  // url.com/api/:season/:matchId
  // random number between range [x,y] (2 ints)
  function rangeBet(string _apiUrl, string[] _keyPath, bytes32 betId, bytes32 _specId, string _callback, address _caller)
    public
    // With this generic bet, we should move validation to consumer
    //validSpec(_specId)
  {
    ChainlinkLib.Run memory run = newRun(DICE_ROLL_ID, _caller, _callback);

    run.add("url", _apiUrl);
    run.addStringArray("path", _keyPath);
    // Can run any Bet
    con = IConsumer(_caller);
    //con.updateRequestId(chainlinkRequest(run, LINK(1)), betId);
  }

  modifier onlyLINK() {
    require(msg.sender == ROPSTEN_LINK_ADDRESS, "Must use LINK token");
    _;
  }

  modifier validExecutionTime(uint256 _delayTime) {
    require( _delayTime < 24 hours && _delayTime > 15 seconds);
    _;
  }
}

interface IConsumer{
  //function updateRequestId(bytes32, bytes32) external;
  function updateRequestId(bytes32) external;
}
