pragma solidity ^0.4.24;

contract LibBet {
  
  struct EIP712Domain {
    string  name;
    string  version;
    uint256 chainId;
    address verifyingContract;
  }

  struct Oracle {
    address contractAddress; 
    uint32 executionTime;
  }

  struct Bet {
    string betId;
    address makerAddress;
    address takerAddress;
    uint32 amount;
    uint256 expirationTime;
    Oracle oracleSpec;
  }

  bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(
    "EIP712Domain(",
    "string name,",
    "string version",
    "uint256 chainId",
    "address verifyingContract",
    ")"
  );

  bytes32 constant ORACLE_TYPEHASH = keccak256(
    "Oracle(",
    "address contractAddress",
    "uint32 executionTime",
    ")"
  );


  bytes32 constant BET_TYPEHASH = keccak256(
    "Bet(",
    "string betId",
    "address makerAddress",
    "address takerAddress",
    "uint32 amount",
    "uint256 expirationTime",
    "Oracle oracleSpec",
    ")",
    "Oracle(",
    "address contractAddress",
    "uint32 executionTime",
    ")"
  );

  bytes32 DOMAIN_SEPARATOR;
  constructor () public {
    DOMAIN_SEPARATOR = hash(EIP712Domain({
        name: "Smart Bets",
        version: '1',
        chainId: 3,
        verifyingContract: this
    }));
  }

  function hash(EIP712Domain _eip712Domain) internal pure returns (bytes32) {
    return keccak256(abi.encode(
      EIP712DOMAIN_TYPEHASH,
      keccak256(bytes(_eip712Domain.name)),
      keccak256(bytes(_eip712Domain.version)),
      _eip712Domain.chainId,
      _eip712Domain.verifyingContract
    ));
  }

  function hash(Oracle _oracle) internal pure returns (bytes32) {
    return keccak256(abi.encode(
      ORACLE_TYPEHASH,
      _oracle.contractAddress,
      _oracle.executionTime
    ));
  }

 function hash(Bet _bet) internal pure returns (bytes32) {
    return keccak256(abi.encode(
      BET_TYPEHASH,
      keccak256(bytes(_bet.betId)),
      _bet.makerAddress,
      _bet.takerAddress,
      _bet.amount,
      _bet.expirationTime,
      hash(_bet.oracleSpec)
    ));
  }

  function eip712Encoding(bytes32 _hashedBet) internal view returns (bytes32) {
    bytes32 digest = keccak256(abi.encodePacked(
      "\x19\x01",
      DOMAIN_SEPARATOR,
      _hashedBet
    ));
    return digest;
  }

  function isValidSignature(bytes32 _hashedBet, address _makerAddress, bytes _signature) internal view returns (bool) {
    return recover(eip712Encoding(_hashedBet), _signature) == _makerAddress;
  }
  
  function recover(bytes32 _digest, bytes _signature) internal pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    // Check the signature length
    if (_signature.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    // ecrecover takes the signature parameters, and the only way to get them
    // currently is to use assembly.
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      r := mload(add(_signature, 32))
      s := mload(add(_signature, 64))
      v := byte(0, mload(add(_signature, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      // solium-disable-next-line arg-overflow
      return ecrecover(_digest, v, r, s);
    }
  }

  /*function test() public view returns (bool) {
      // Example signed message
      Bet memory bet = Bet({
          betId: "BET_ID_STRING",
          makerAddress: 0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826,
          takerAddress: 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB,
          amount: 300,
          expirationTime: 777,
          oracleSpec: Oracle({
              contractAddress: 0x4d946f2f0ba8e05da189b024b6592a712c1d85a3,
              executionTime: 1000
          })
      });
      uint8 v = 28;
      bytes32 r = 0x4355c47d63924e8a72e509b65029052eb6c299d53a04e167c5775fd466751c9d;
      bytes32 s = 0x07299936d304c153f6443dfa05f40ff007d72911b6f72307f996231605b91562;
      
      // My (all values below) will be different
      assert(DOMAIN_SEPARATOR == 0xf2cee375fa42b42143804025fc449deafd50cc031ca257e0b194a650a912090f);
      assert(hash(bet) == 0xc52c0ee5d84264471806290a3f2c4cecfc5490626bf912d01f240d7a274b371e);
      assert(verify(bet, v, r, s));
      return true;
  }*/
}