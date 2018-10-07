pragma solidity ^0.4.24;

import "./LibBet.sol";

contract SmartBet is LibBet {
  function assertStartableBet(Bet _bet, address _takerAddress, bytes _signature) internal {

    // Check the taker address if specified
    if (_bet.takerAddress != address(0)) {
      require(_bet.takerAddress == _takerAddress, "Invalid taker address");
    }

    // Validate the Bet maker's signature and address
    require(
      isValidSignature(
        hash(_bet),
        _bet.makerAddress,
        _signature
      ),
      "Invalid bet signature"
    );

  }

  function delay(uint256 _executionTime) internal returns(uint256) {
    return _executionTime - now;
  }
}
