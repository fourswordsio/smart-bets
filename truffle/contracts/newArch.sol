pragma solidity ^0.4.24;

// File: solidity-cborutils/contracts/Buffer.sol

library Buffer {
    struct buffer {
        bytes buf;
        uint capacity;
    }

    function init(buffer memory buf, uint capacity) internal pure {
        if(capacity % 32 != 0) capacity += 32 - (capacity % 32);
        // Allocate space for the buffer data
        buf.capacity = capacity;
        assembly {
            let ptr := mload(0x40)
            mstore(buf, ptr)
            mstore(ptr, 0)
            mstore(0x40, add(ptr, capacity))
        }
    }

    function resize(buffer memory buf, uint capacity) private pure {
        bytes memory oldbuf = buf.buf;
        init(buf, capacity);
        append(buf, oldbuf);
    }

    function max(uint a, uint b) private pure returns(uint) {
        if(a > b) {
            return a;
        }
        return b;
    }

    /**
     * @dev Appends a byte array to the end of the buffer. Resizes if doing so
     * would exceed the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param data The data to append.
     * @return The original buffer.
     */
    function append(buffer memory buf, bytes data) internal pure returns(buffer memory) {
        if(data.length + buf.buf.length > buf.capacity) {
            resize(buf, max(buf.capacity, data.length) * 2);
        }

        uint dest;
        uint src;
        uint len = data.length;
        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Length of existing buffer data
            let buflen := mload(bufptr)
            // Start address = buffer address + buffer length + sizeof(buffer length)
            dest := add(add(bufptr, buflen), 32)
            // Update buffer length
            mstore(bufptr, add(buflen, mload(data)))
            src := add(data, 32)
        }

        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }

        return buf;
    }

    /**
     * @dev Appends a byte to the end of the buffer. Resizes if doing so would
     * exceed the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param data The data to append.
     * @return The original buffer.
     */
    function append(buffer memory buf, uint8 data) internal pure {
        if(buf.buf.length + 1 > buf.capacity) {
            resize(buf, buf.capacity * 2);
        }

        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Length of existing buffer data
            let buflen := mload(bufptr)
            // Address = buffer address + buffer length + sizeof(buffer length)
            let dest := add(add(bufptr, buflen), 32)
            mstore8(dest, data)
            // Update buffer length
            mstore(bufptr, add(buflen, 1))
        }
    }

    /**
     * @dev Appends a byte to the end of the buffer. Resizes if doing so would
     * exceed the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param data The data to append.
     * @return The original buffer.
     */
    function appendInt(buffer memory buf, uint data, uint len) internal pure returns(buffer memory) {
        if(len + buf.buf.length > buf.capacity) {
            resize(buf, max(buf.capacity, len) * 2);
        }

        uint mask = 256 ** len - 1;
        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Length of existing buffer data
            let buflen := mload(bufptr)
            // Address = buffer address + buffer length + sizeof(buffer length) + len
            let dest := add(add(bufptr, buflen), len)
            mstore(dest, or(and(mload(dest), not(mask)), data))
            // Update buffer length
            mstore(bufptr, add(buflen, len))
        }
        return buf;
    }
}

// File: solidity-cborutils/contracts/CBOR.sol

library CBOR {
    using Buffer for Buffer.buffer;

    uint8 private constant MAJOR_TYPE_INT = 0;
    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;
    uint8 private constant MAJOR_TYPE_BYTES = 2;
    uint8 private constant MAJOR_TYPE_STRING = 3;
    uint8 private constant MAJOR_TYPE_ARRAY = 4;
    uint8 private constant MAJOR_TYPE_MAP = 5;
    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;

    function encodeType(Buffer.buffer memory buf, uint8 major, uint value) private pure {
        if(value <= 23) {
            buf.append(uint8((major << 5) | value));
        } else if(value <= 0xFF) {
            buf.append(uint8((major << 5) | 24));
            buf.appendInt(value, 1);
        } else if(value <= 0xFFFF) {
            buf.append(uint8((major << 5) | 25));
            buf.appendInt(value, 2);
        } else if(value <= 0xFFFFFFFF) {
            buf.append(uint8((major << 5) | 26));
            buf.appendInt(value, 4);
        } else if(value <= 0xFFFFFFFFFFFFFFFF) {
            buf.append(uint8((major << 5) | 27));
            buf.appendInt(value, 8);
        }
    }

    function encodeIndefiniteLengthType(Buffer.buffer memory buf, uint8 major) private pure {
        buf.append(uint8((major << 5) | 31));
    }

    function encodeUInt(Buffer.buffer memory buf, uint value) internal pure {
        encodeType(buf, MAJOR_TYPE_INT, value);
    }

    function encodeInt(Buffer.buffer memory buf, int value) internal pure {
        if(value >= 0) {
            encodeType(buf, MAJOR_TYPE_INT, uint(value));
        } else {
            encodeType(buf, MAJOR_TYPE_NEGATIVE_INT, uint(-1 - value));
        }
    }

    function encodeBytes(Buffer.buffer memory buf, bytes value) internal pure {
        encodeType(buf, MAJOR_TYPE_BYTES, value.length);
        buf.append(value);
    }

    function encodeString(Buffer.buffer memory buf, string value) internal pure {
        encodeType(buf, MAJOR_TYPE_STRING, bytes(value).length);
        buf.append(bytes(value));
    }

    function startArray(Buffer.buffer memory buf) internal pure {
        encodeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);
    }

    function startMap(Buffer.buffer memory buf) internal pure {
        encodeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);
    }

    function endSequence(Buffer.buffer memory buf) internal pure {
        encodeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);
    }
}

// File: ../solidity/contracts/ChainlinkLib.sol

library ChainlinkLib {
  bytes4 internal constant oracleRequestDataFid = bytes4(keccak256("requestData(address,uint256,uint256,bytes32,address,bytes4,bytes32,bytes)"));

  using CBOR for Buffer.buffer;

  struct Run {
    bytes32 specId;
    address callbackAddress;
    bytes4 callbackFunctionId;
    bytes32 requestId;
    Buffer.buffer buf;
  }

  function initialize(
    Run memory self,
    bytes32 _specId,
    address _callbackAddress,
    string _callbackFunctionSignature
  ) internal pure returns (ChainlinkLib.Run memory) {
    Buffer.init(self.buf, 128);
    self.specId = _specId;
    self.callbackAddress = _callbackAddress;
    self.callbackFunctionId = bytes4(keccak256(bytes(_callbackFunctionSignature)));
    self.buf.startMap();
    return self;
  }

  function encodeForOracle(
    Run memory self,
    uint256 _clArgsVersion
  ) internal pure returns (bytes memory) {
    return abi.encodeWithSelector(
      oracleRequestDataFid,
      0, // overridden by onTokenTransfer
      0, // overridden by onTokenTransfer
      _clArgsVersion,
      self.specId,
      self.callbackAddress,
      self.callbackFunctionId,
      self.requestId,
      self.buf.buf);
  }

  function add(Run memory self, string _key, string _value)
    internal pure
  {
    self.buf.encodeString(_key);
    self.buf.encodeString(_value);
  }

  function addBytes(Run memory self, string _key, bytes _value)
    internal pure
  {
    self.buf.encodeString(_key);
    self.buf.encodeBytes(_value);
  }

  function addInt(Run memory self, string _key, int256 _value)
    internal pure
  {
    self.buf.encodeString(_key);
    self.buf.encodeInt(_value);
  }

  function addUint(Run memory self, string _key, uint256 _value)
    internal pure
  {
    self.buf.encodeString(_key);
    self.buf.encodeUInt(_value);
  }

  function addStringArray(Run memory self, string _key, string[] memory _values)
    internal pure
  {
    self.buf.encodeString(_key);
    self.buf.startArray();
    for (uint256 i = 0; i < _values.length; i++) {
      self.buf.encodeString(_values[i]);
    }
    self.buf.endSequence();
  }

  function close(Run memory self) internal pure {
    self.buf.endSequence();
  }
}

// File: ../solidity/contracts/ENSResolver.sol

contract ENSResolver {
  function addr(bytes32 node) public view returns (address);
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: link_token/contracts/token/linkERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract linkERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: link_token/contracts/token/linkERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract linkERC20 is linkERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: link_token/contracts/token/ERC677.sol

contract ERC677 is linkERC20 {
  function transferAndCall(address to, uint value, bytes data) returns (bool success);

  event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

// File: link_token/contracts/token/ERC677Receiver.sol

contract ERC677Receiver {
  function onTokenTransfer(address _sender, uint _value, bytes _data);
}

// File: link_token/contracts/ERC677Token.sol

contract ERC677Token is ERC677 {

  /**
  * @dev transfer token to a contract address with additional data if the recipient is a contact.
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  * @param _data The extra data to be passed to the receiving contract.
  */
  function transferAndCall(address _to, uint _value, bytes _data)
    public
    returns (bool success)
  {
    super.transfer(_to, _value);
    Transfer(msg.sender, _to, _value, _data);
    if (isContract(_to)) {
      contractFallback(_to, _value, _data);
    }
    return true;
  }


  // PRIVATE

  function contractFallback(address _to, uint _value, bytes _data)
    private
  {
    ERC677Receiver receiver = ERC677Receiver(_to);
    receiver.onTokenTransfer(msg.sender, _value, _data);
  }

  function isContract(address _addr)
    private
    returns (bool hasCode)
  {
    uint length;
    assembly { length := extcodesize(_addr) }
    return length > 0;
  }

}

// File: link_token/contracts/math/linkSafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library linkSafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: link_token/contracts/token/linkBasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract linkBasicToken is linkERC20Basic {
  using linkSafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

// File: link_token/contracts/token/linkStandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract linkStandardToken is linkERC20, linkBasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
  
    /*
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until 
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) 
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) 
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: link_token/contracts/LinkToken.sol

contract LinkToken is linkStandardToken, ERC677Token {

  uint public constant totalSupply = 10**27;
  string public constant name = 'ChainLink Token';
  uint8 public constant decimals = 18;
  string public constant symbol = 'LINK';

  function LinkToken()
    public
  {
    balances[msg.sender] = totalSupply;
  }

  /**
  * @dev transfer token to a specified address with additional data if the recipient is a contract.
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  * @param _data The extra data to be passed to the receiving contract.
  */
  function transferAndCall(address _to, uint _value, bytes _data)
    public
    validRecipient(_to)
    returns (bool success)
  {
    return super.transferAndCall(_to, _value, _data);
  }

  /**
  * @dev transfer token to a specified address.
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint _value)
    public
    validRecipient(_to)
    returns (bool success)
  {
    return super.transfer(_to, _value);
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value)
    public
    validRecipient(_spender)
    returns (bool)
  {
    return super.approve(_spender,  _value);
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value)
    public
    validRecipient(_to)
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }


  // MODIFIERS

  modifier validRecipient(address _recipient) {
    require(_recipient != address(0) && _recipient != address(this));
    _;
  }

}

// File: ../solidity/contracts/Oracle.sol

contract Oracle is Ownable {
  using SafeMath for uint256;

  LinkToken internal LINK;

  struct Callback {
    bytes32 externalId;
    uint256 amount;
    address addr;
    bytes4 functionId;
    uint64 cancelExpiration;
  }

  // We initialize fields to 1 instead of 0 so that the first invocation
  // does not cost more gas.
  uint256 constant private oneForConsistentGasCost = 1;
  uint256 private withdrawableWei = oneForConsistentGasCost;

  mapping(uint256 => Callback) private callbacks;

  event RunRequest(
    bytes32 indexed specId,
    address indexed requester,
    uint256 indexed amount,
    uint256 internalId,
    uint256 version,
    bytes data
  );

  event CancelRequest(
    uint256 internalId
  );

  constructor(address _link) Ownable() public {
    LINK = LinkToken(_link);
  }

  function onTokenTransfer(
    address _sender,
    uint256 _amount,
    bytes _data
  )
    public
    onlyLINK
    permittedFunctionsForLINK
  {
    assembly {
      // solium-disable-next-line security/no-low-level-calls
      mstore(add(_data, 36), _sender) // ensure correct sender is passed
      // solium-disable-next-line security/no-low-level-calls
      mstore(add(_data, 68), _amount)    // ensure correct amount is passed
    }
    // solium-disable-next-line security/no-low-level-calls
    require(address(this).delegatecall(_data), "Unable to create request"); // calls requestData
  }

  function requestData(
    address _sender,
    uint256 _amount,
    uint256 _version,
    bytes32 _specId,
    address _callbackAddress,
    bytes4 _callbackFunctionId,
    bytes32 _externalId,
    bytes _data
  )
    public
    onlyLINK
  {
    uint256 internalId = uint256(keccak256(abi.encodePacked(_sender, _externalId)));
    callbacks[internalId] = Callback(
      _externalId,
      _amount,
      _callbackAddress,
      _callbackFunctionId,
      uint64(now.add(5 minutes)));
    emit RunRequest(
      _specId,
      _sender,
      _amount,
      internalId,
      _version,
      _data);
  }

  function fulfillData(
    uint256 _internalId,
    bytes32 _data
  )
    public
    onlyOwner
    hasInternalId(_internalId)
  {
    Callback memory callback = callbacks[_internalId];
    withdrawableWei = withdrawableWei.add(callback.amount);
    delete callbacks[_internalId];
    // All updates to the oracle's fulfillment should come before calling the
    // callback(addr+functionId) as it is untrusted.
    // See: https://solidity.readthedocs.io/en/develop/security-considerations.html#use-the-checks-effects-interactions-pattern
    callback.addr.call(callback.functionId, callback.externalId, _data); // solium-disable-line security/no-low-level-calls
  }

  function withdraw(address _recipient, uint256 _amount)
    public
    onlyOwner
    hasAvailableFunds(_amount)
  {
    withdrawableWei = withdrawableWei.sub(_amount);
    LINK.transfer(_recipient, _amount);
  }

  function cancel(bytes32 _externalId)
    public
  {
    uint256 internalId = uint256(keccak256(abi.encodePacked(msg.sender, _externalId)));
    require(msg.sender == callbacks[internalId].addr, "Must be called from requester");
    require(callbacks[internalId].cancelExpiration <= now, "Request is not expired");
    Callback memory cb = callbacks[internalId];
    require(LINK.transfer(cb.addr, cb.amount), "Unable to transfer");
    delete callbacks[internalId];
    emit CancelRequest(internalId);
  }

  // MODIFIERS

  modifier hasAvailableFunds(uint256 _amount) {
    require(withdrawableWei >= _amount.add(oneForConsistentGasCost), "Amount requested is greater than withdrawable balance");
    _;
  }

  modifier hasInternalId(uint256 _internalId) {
    require(callbacks[_internalId].addr != address(0), "Must have a valid internalId");
    _;
  }

  modifier onlyLINK() {
    require(msg.sender == address(LINK), "Must use LINK token");
    _;
  }

  bytes4 constant private permittedFunc = bytes4(keccak256("requestData(address,uint256,uint256,bytes32,address,bytes4,bytes32,bytes)"));

  modifier permittedFunctionsForLINK() {
    bytes4[1] memory funcSelector;
    assembly {
      // solium-disable-next-line security/no-low-level-calls
      calldatacopy(funcSelector, 132, 4) // grab function selector from calldata
    }
    require(funcSelector[0] == permittedFunc, "Must use whitelisted functions");
    _;
  }

}

// File: @ensdomains/ens/contracts/ENS.sol

interface ENS {

    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    // Logged when the owner of a node transfers ownership to a new account.
    event Transfer(bytes32 indexed node, address owner);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed node, address resolver);

    // Logged when the TTL of a node changes
    event NewTTL(bytes32 indexed node, uint64 ttl);


    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) public;
    function setResolver(bytes32 node, address resolver) public;
    function setOwner(bytes32 node, address owner) public;
    function setTTL(bytes32 node, uint64 ttl) public;
    function owner(bytes32 node) public view returns (address);
    function resolver(bytes32 node) public view returns (address);
    function ttl(bytes32 node) public view returns (uint64);

}

// File: ../solidity/contracts/Chainlinked.sol

contract Chainlinked {
  using ChainlinkLib for ChainlinkLib.Run;
  using SafeMath for uint256;

  uint256 constant private clArgsVersion = 1;
  uint256 constant private linkDivisibility = 10**18;

  LinkToken private link;
  Oracle private oracle;
  uint256 private requests = 1;
  mapping(bytes32 => address) private unfulfilledRequests;

  ENS private ens;
  bytes32 private ensNode;
  bytes32 constant private ensTokenSubname = keccak256("link");
  bytes32 constant private ensOracleSubname = keccak256("oracle");

  event ChainlinkRequested(bytes32 id);
  event ChainlinkFulfilled(bytes32 id);
  event ChainlinkCancelled(bytes32 id);

  function newRun(
    bytes32 _specId,
    address _callbackAddress,
    string _callbackFunctionSignature
  ) internal pure returns (ChainlinkLib.Run memory) {
    ChainlinkLib.Run memory run;
    return run.initialize(_specId, _callbackAddress, _callbackFunctionSignature);
  }

  function chainlinkRequest(ChainlinkLib.Run memory _run, uint256 _amount)
    internal
    returns (bytes32)
  {
    _run.requestId = bytes32(requests);
    requests += 1;
    _run.close();
    unfulfilledRequests[_run.requestId] = oracle;
    emit ChainlinkRequested(_run.requestId);
    require(link.transferAndCall(oracle, _amount, _run.encodeForOracle(clArgsVersion)), "unable to transferAndCall to oracle");

    return _run.requestId;
  }

  function cancelChainlinkRequest(bytes32 _requestId)
    internal
  {
    delete unfulfilledRequests[_requestId];
    emit ChainlinkCancelled(_requestId);
    oracle.cancel(_requestId);
  }

  function LINK(uint256 _amount) internal view returns (uint256) {
    return _amount.mul(linkDivisibility);
  }

  function setOracle(address _oracle) internal {
    oracle = Oracle(_oracle);
  }

  function setLinkToken(address _link) internal {
    link = LinkToken(_link);
  }

  function chainlinkToken()
    internal
    view
    returns (address)
  {
    return address(link);
  }

  function newChainlinkWithENS(address _ens, bytes32 _node)
    internal
    returns (address, address)
  {
    ens = ENS(_ens);
    ensNode = _node;
    ENSResolver resolver = ENSResolver(ens.resolver(ensNode));
    bytes32 linkSubnode = keccak256(abi.encodePacked(ensNode, ensTokenSubname));
    setLinkToken(resolver.addr(linkSubnode));
    return (link, updateOracleWithENS());
  }

  function updateOracleWithENS()
    internal
    returns (address)
  {
    ENSResolver resolver = ENSResolver(ens.resolver(ensNode));
    bytes32 oracleSubnode = keccak256(abi.encodePacked(ensNode, ensOracleSubname));
    setOracle(resolver.addr(oracleSubnode));
    return oracle;
  }

  modifier checkChainlinkFulfillment(bytes32 _requestId) {
    require(msg.sender == unfulfilledRequests[_requestId], "source must be the oracle of the request");
    _;
    delete unfulfilledRequests[_requestId];
    emit ChainlinkFulfilled(_requestId);
  }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

contract Requester is Chainlinked, Ownable {

  address constant ROPSTEN_LINK_ADDRESS = 0x20fE562d797A42Dcb3399062AE9546cd06f63280;
  //address constant ROPSTEN_ORACLE_ADDRESS = 0xcec1b9Cf49d76ABf21206bDa4b2055bA149b28E6;
  address constant ROPSTEN_ORACLE_ADDRESS = 0x261a3f70acdc85cfc2ffc8bade43b1d42bf75d69; // this one has our specID
  bytes32 constant DELAYED_PRICE_ID = bytes32("dc56d871480a4787bb076917ceda0699");

  IConsumer internal con;
  
  uint256 private currentAmount;
  address private currentSender;

  event RequestFulfilled(
    bytes32 indexed requestId,
    uint256 indexed price
  );

  constructor() Ownable() public {
    setLinkToken(ROPSTEN_LINK_ADDRESS);
    setOracle(ROPSTEN_ORACLE_ADDRESS);
  }

  function onTokenTransfer(
    address _sender,
    uint256 _wei,
    bytes _data
  )
    public
    onlyLINK
    isContract(_sender)
  {
    require(_data.length > 0, "tokenTransfer requires abi bytes");
    currentAmount = _wei;
    currentSender = _sender;
    require(address(this).delegatecall(_data), "onTokenTransfer failing");
  }

  // TODO: Update this to use "run" and our delay spec
  /*function lastEthPrice(bytes32 _betId, string _callback) public returns(bytes32,bytes32) {
    string[] memory tasks = new string[](5);
    tasks[0] = "httpget";
    tasks[1] = "jsonparse";
    tasks[2] = "multiply";
    tasks[3] = "ethuint256";
    tasks[4] = "ethtx";

    ChainlinkLib.Spec memory spec = newSpec(tasks, currentSender, _callback);
    spec.add("url", "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD");
    string[] memory path = new string[](1);
    path[0] = "USD";
    spec.addStringArray("path", path);
    spec.addInt("times", 100);
    con = IConsumer(currentSender);
    con.updateRequestId(chainlinkRequest(spec, currentAmount), _betId);
  }*/

  // Updated to use "run" and prebuilt specID
  function lastEthPrice(bytes32 _betId, string _callback) public returns(bytes32,bytes32) {
    ChainlinkLib.Run memory run = newRun(DELAYED_PRICE_ID, currentSender, _callback);

    run.add("url", "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD");
    string[] memory path = new string[](1);
    path[0] = "USD";
    run.addStringArray("path", path);

    //run.addUint("until", now + _delayTime);   
    run.addUint("until", now + 15); // TODO: Pass delayTime as param
    con = IConsumer(currentSender);
    con.updateRequestId(chainlinkRequest(run, currentAmount), _betId);
  }

  modifier isContract(address _addr) {
    uint length;
    assembly { length := extcodesize(_addr) }
    require(length > 0, "must be a contract");
    _;
  }

  modifier onlyLINK() {
    //require(msg.sender == address(link));
    require(msg.sender == 0x20fE562d797A42Dcb3399062AE9546cd06f63280, "Must use LINK token");
    //require(msg.sender == address(LINK), "Must use LINK token");
    _;
  }
}

interface IConsumer{
  function updateRequestId(bytes32, bytes32) external;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Consumer could be any bet type we would want to allow
// Bet type parameters still need to be specified in requester contract.
// This would make it so we can choose which bets are allowed
contract Consumer is Ownable {

  address constant ROPSTEN_LINK_ADDRESS = 0x20fE562d797A42Dcb3399062AE9546cd06f63280;
  address constant ROPSTEN_ORACLE_ADDRESS = 0xcec1b9Cf49d76ABf21206bDa4b2055bA149b28E6;
  bytes32 constant byteText = "twochains"; 
  //string public converted; 
  bytes32 public returnedBetId;

  uint256 constant private linkDivisibility = 10**18;

  // Store bets
  uint256 public lastPrice;
  uint256 public lastPriceTimestamp;

  mapping(bytes32 => bool) internal unfulfilledRequests;
  
  bytes4 constant LAST_PRICE_FID = bytes4(keccak256("lastEthPrice(string)"));

  address internal requester;
  address internal oracle;
  //ILinkToken internal link;
  LinkToken internal link;

  struct Request {
    bytes4 fid;
    bytes32 betId;
    string callback;
  }
  
  constructor(address _requester) public Ownable() {
    oracle = ROPSTEN_ORACLE_ADDRESS;
    //link = ILinkToken(ROPSTEN_LINK_ADDRESS);
    link =  LinkToken(ROPSTEN_LINK_ADDRESS);
    requester = _requester;
  }

  event RequestFulfilled(
    bytes32 requestId,
    uint256 price
  );
  
  function requestLastCryptoPrice() public {
    Request memory self;
    self.fid = LAST_PRICE_FID;
    self.betId = byteText;
    self.callback = "fulfillLastPrice(bytes32,uint256)";
    //require(link.transferAndCall(requester, linkDivisibility, encodeData(self)));
    require(link.transferAndCall(requester, 1, encodeData(self)), "Failing to request last crypto price");
  }
  
  function encodeData(Request req) internal pure returns (bytes data) {
    return abi.encodeWithSelector(req.fid, req.callback, req.betId);
  }

  function updateRequestId(bytes32 _requestId, bytes32 _betId) external onlyRequester {
    unfulfilledRequests[_requestId] = true;
    returnedBetId = _betId;
  }

  function fulfillLastPrice(bytes32 _requestId, uint256 _price)
    public
    checkChainlinkFulfillment(_requestId)
  {
    emit RequestFulfilled(_requestId, _price);
    lastPriceTimestamp = now;
    lastPrice = _price;
  }

  function withdrawLink() public onlyOwner {
    require(link.transfer(owner, link.balanceOf(address(this))));
  }
  
  modifier checkChainlinkFulfillment(bytes32 _requestId) {
    require(msg.sender == oracle && unfulfilledRequests[_requestId], "Source must be the oracle of the request");
    _;
    unfulfilledRequests[_requestId] = false;
    //delete unfulfilledRequests[_requestId];
  }
  
  modifier onlyRequester() {
    require(msg.sender == requester, "Only the requester can run this function");
    _;
  }
}

interface ILinkToken{
  function transferAndCall(address, uint, bytes) external returns (bool);
  function transfer(address, uint) external returns (bool);
  function balanceOf(address) external view returns (uint256);
}