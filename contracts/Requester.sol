pragma solidity ^0.4.24;

import "./ChainlinkContracts.sol";

contract Requester is Chainlinked, Ownable {

  address constant ROPSTEN_LINK_ADDRESS = 0x20fE562d797A42Dcb3399062AE9546cd06f63280;
  address constant ROPSTEN_ORACLE_ADDRESS = 0x261a3f70acdc85cfc2ffc8bade43b1d42bf75d69; // this one has our specID
  bytes32 constant DELAYED_PRICE_ID = bytes32("dc56d871480a4787bb076917ceda0699");

  IConsumer internal con;

  event RequestFulfilled(
    bytes32 indexed requestId,
    uint256 indexed price
  );

  constructor() Ownable() public {
    setLinkToken(ROPSTEN_LINK_ADDRESS);
    setOracle(ROPSTEN_ORACLE_ADDRESS);
  }

  function lastEthPrice(string _callback, address _caller, uint256 _delay)
    public
    validExecutionTime(_delay)
    returns(bytes32)
  {
    ChainlinkLib.Run memory run = newRun(DELAYED_PRICE_ID, _caller, _callback);

    run.add("url", "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD");
    string[] memory path = new string[](1);
    path[0] = "USD";
    run.addStringArray("path", path);

    run.addInt("times", 100);
    run.addUint("until", now + _delay);
    con = IConsumer(_caller);
    con.updateRequestId(chainlinkRequest(run, LINK(1)));
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
  function updateRequestId(bytes32) external;
}
