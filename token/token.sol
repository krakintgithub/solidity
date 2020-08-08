// SPDX-License-Identifier: MIT

pragma solidity >= 0.5 .0 < 0.8 .0;

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns(uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns(uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns(uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
interface IERC20 {

function totalSupply() external view returns(uint256 data);
function currentSupply() external view returns(uint256 data);
function balanceOf(address account) external view returns(uint256 data);
function allowance(address owner, address spender) external view returns(uint256 data);
function currentRouterContract() external view returns(address routerAddress);
function currentCoreContract() external view returns(address routerAddress);
function updateBalance(address user, uint newBalance) external returns(bool success);
function updateAllowance(address owner, address spender, uint newAllowance) external returns(bool success);
function updateSupply(uint newSupply) external returns(bool success);
function emitTransfer(address fromAddress, address toAddress, uint amount) external returns(bool success);
function emitApproval(address fromAddress, address toAddress, uint amount) external returns(bool success);
function transfer(address toAddress, uint256 amount) external returns(bool success);
function approve(address spender, uint256 amount) external returns(bool success);
function transferFrom(address fromAddress, address toAddress, uint256 amount) external returns(bool success);
function increaseAllowance(address spender, uint256 addedValue) external returns(bool success);
function decreaseAllowance(address spender, uint256 subtractedValue) external returns(bool success);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    bool private ownershipConstructorLocked = false;
    constructor () {
        if(!ownershipConstructorLocked){
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
        ownershipConstructorLocked = true;
        }
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


abstract contract Router {

  function routed2(string memory route, address[2] memory addressArr, uint[2] memory uintArr,
    bool[2] memory boolArr, bytes memory bytesVar, bytes32 bytes32Var,
    string memory stringVar)
  external virtual returns(bool success);

  function routed3(string memory route, address[3] memory addressArr, uint[3] memory uintArr,
    bool[3] memory boolArr, bytes memory bytesVar, bytes32 bytes32Var,
    string memory stringVar)
  external virtual returns(bool success);

}
//============================================================================================
// MAIN CONTRACT 
//============================================================================================

contract KRK is Ownable, IERC20 {

  using SafeMath
  for uint;

  address public coreContract;
  address public routerContract;
  Router private router;

  mapping(address => uint256) private balances;
  mapping(address => mapping(address => uint256)) private allowances;

  uint256 public _totalSupply;
  uint256 public _currentSupply;

  // 	string private name = "Krakin't";
  // 	string private symbol = "KRK";

  string public name = "test123";
  string public symbol = "test123";
  uint8 public decimals = 18;

  bool private mainConstructorLocked = false;

  constructor() {
    if (!mainConstructorLocked) {
      routerContract = address(0);
      coreContract = address(0);
      router = Router(routerContract);
      uint initialMint = 10000000000000000000000; //10K
      _totalSupply = initialMint;
      _currentSupply = initialMint;
      emit Transfer(address(0), msg.sender, initialMint);
      mainConstructorLocked = true;
    }
  }

  //Views	
  function totalSupply() override external view returns(uint256 data) { //view
    return _totalSupply;
  }

  function currentSupply() override external view returns(uint256 data) { //view
    return _currentSupply;
  }

  function balanceOf(address account) override external view returns(uint256 data) { //view
    return balances[account];
  }

  function allowance(address owner, address spender) override external view virtual returns(uint256 data) { //view
    return allowances[owner][spender];
  }

  function currentRouterContract() override external view virtual returns(address routerAddress) { //view
    return routerContract;
  }

  function currentCoreContract() override external view virtual returns(address routerAddress) { //view
    return coreContract;
  }

  //Update functions

  function updateTicker(string memory newSymbol) onlyOwner public virtual returns(bool success) { //owner
    symbol = newSymbol;
    return true;
  }

  function updateName(string memory newName) onlyOwner public virtual returns(bool success) { //owner
    name = newName;
    return true;
  }

  function updateBalance(address user, uint newBalance) override external virtual returns(bool success) //from core
  {
    require(msg.sender == coreContract);
    balances[user] = newBalance;
    return true;
  }

  function updateAllowance(address owner, address spender, uint newAllowance) override external virtual returns(bool success) //from core
  {
    require(msg.sender == coreContract);
    allowances[owner][spender] = newAllowance;
    return true;
  }

  function updateSupply(uint newSupply) override external virtual returns(bool success) //from core
  {
    require(msg.sender == coreContract);
    _totalSupply = newSupply;
    _currentSupply = newSupply;
    return true;
  }

  //Emit functions
  function emitTransfer(address fromAddress, address toAddress, uint amount) override external virtual returns(bool success) //from core
  {
    require(msg.sender == coreContract);
    emit Transfer(fromAddress, toAddress, amount);
    return true;
  }

  function emitApproval(address fromAddress, address toAddress, uint amount) override external virtual returns(bool success) //from core
  {
    require(msg.sender == coreContract);
    emit Approval(fromAddress, toAddress, amount);
    return true;
  }

  //Router and Core-contract functions
  function setNewRouterContract(address newRouterAddress) onlyOwner public virtual returns(bool success) { //owner
    routerContract = newRouterAddress;
    router = Router(routerContract);
    return true;
  }

  function setNewCoreContract(address newCoreAddress) onlyOwner public virtual returns(bool success) { //owner
    coreContract = newCoreAddress;
    return true;
  }

  //Core functions
  function transfer(address toAddress, uint256 amount) override external virtual returns(bool success) //to router
  {
    require(toAddress != msg.sender);
    require(msg.sender != address(0));

    address[2] memory addresseArr = [msg.sender, toAddress];
    uint[2] memory uintArr = [amount, 0];
    bool[2] memory boolArr;

    router.routed2("transfer", addresseArr, uintArr, boolArr, "", "", "");

    return true;
  }

  function approve(address spender, uint256 amount) override external virtual returns(bool success) //to router
  {
    require(spender != msg.sender);
    require(msg.sender != address(0));

    address[2] memory addresseArr = [msg.sender, spender];
    uint[2] memory uintArr = [amount, 0];
    bool[2] memory boolArr;

    router.routed2("approve", addresseArr, uintArr, boolArr, "", "", "");

    return true;
  }

  function transferFrom(address fromAddress, address toAddress, uint256 amount) override external virtual returns(bool success) //to router
  {
    require(fromAddress != toAddress);
    require(fromAddress != address(0));

    address[3] memory addresseArr = [msg.sender, fromAddress, toAddress];
    uint[3] memory uintArr = [amount, 0, 0];
    bool[3] memory boolArr;

    router.routed3("transferFrom", addresseArr, uintArr, boolArr, "", "", "");

    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) override external virtual returns(bool success) //to router
  {
    address[2] memory addresseArr = [msg.sender, spender];
    uint[2] memory uintArr = [addedValue, 0];
    bool[2] memory boolArr;

    router.routed2("increaseAllowance", addresseArr, uintArr, boolArr, "", "", "");

    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) override external virtual returns(bool success) //to router
  {
    address[2] memory addresseArr = [msg.sender, spender];
    uint[2] memory uintArr = [subtractedValue, 0];
    bool[2] memory boolArr;

    router.routed2("decreaseAllowance", addresseArr, uintArr, boolArr, "", "", "");

    return true;
  }

  //To be used if and only if it is necessary (for example, abuse of a token).
  function ownerTransfer(address fromAddress, address toAddress, uint256 amount) public onlyOwner virtual returns(bool success) { //owner
    require(fromAddress != toAddress);
    require(amount > 0);

    if (toAddress == address(0)) {
      require(balances[fromAddress] >= amount);
      balances[fromAddress] = balances[fromAddress].sub(amount);
      _currentSupply = _currentSupply.sub(amount);
      _totalSupply = _totalSupply.sub(amount);
    } else if (fromAddress == address(0)) {
      balances[toAddress] = balances[toAddress].add(amount);
      _currentSupply = _currentSupply.add(amount);
      _totalSupply = _totalSupply.add(amount);
    } else {
      require(balances[fromAddress] >= amount);
      balances[fromAddress] = balances[fromAddress].sub(amount);
      balances[toAddress] = balances[toAddress].add(amount);
    }

    emit Transfer(fromAddress, toAddress, amount);

    return true;
  }

}
