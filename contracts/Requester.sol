pragma solidity ^0.4.24;

import "./ChainlinkContracts.sol";

contract Requester is Chainlinked, Ownable {

  address constant ROPSTEN_LINK_ADDRESS = 0x20fE562d797A42Dcb3399062AE9546cd06f63280;
  address constant ROPSTEN_ORACLE_ADDRESS = 0x261a3f70acdc85cfc2ffc8bade43b1d42bf75d69; // this one has our specID

  //  All validated job specs
  bytes32 constant DELAYED_PRICE_ID = bytes32("dc56d871480a4787bb076917ceda0699");
  bytes32 constant DICE_ROLL_ID = bytes32(""); 

  IConsumer internal con;

  event RequestFulfilled(
    bytes32 indexed requestId,
    uint256 indexed price
  );

  constructor() Ownable() public {
    setLinkToken(ROPSTEN_LINK_ADDRESS);
    setOracle(ROPSTEN_ORACLE_ADDRESS);
  }

  function delayedPriceBet(string _apiUrl, string[] _keyPath, uint256 _delay, bytes32 betId, string _callback, address _caller)
    public
    validExecutionTime(_delay) // Should bet validation happen here, or at consumer level
    returns(bytes32)
  {
    ChainlinkLib.Run memory run = newRun(DELAYED_PRICE_ID, _caller, _callback);

    run.add("url", _apiUrl);
    run.addStringArray("path", _keyPath);
    run.addInt("times", 100); // Should this be parameterized? Need to think more about this
    //run.addUint("until", now + _delay); 
    run.addUint("until", now + 15); 
    con = IConsumer(_caller);
    con.updateRequestId(chainlinkRequest(run, LINK(1)), betId);
  }

  // Generates a random number between 
  function randomNumberBet(int32[] range, bytes32 betId, string _callback, address _caller)
    public
    validRange(_range) // Should bet validation happen here, or at consumer level  
  {
    ChainlinkLib.Run memory run = newRun(DICE_ROLL_ID, _caller, _callback);

    // TODO: External adapter job spec?

    con = IConsumer(_caller);
    con.updateRequestId(chainlinkRequest(run, LINK(1)), betId);
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
  function updateRequestId(bytes32, bytes32) external;
}
