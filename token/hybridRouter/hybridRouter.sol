// SPDX-License-Identifier: MIT

pragma solidity = 0.7 .0;

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

}

abstract contract Context {
  function _msgSender() internal view virtual returns(address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns(bytes memory) {
    this;
    return msg.data;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns(address) {
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

interface IERC20 {

  function currentTokenContract() external view returns(address routerAddress);

  function getExternalContractAddress(string memory contractName) external view returns(address routerAddress);

  function callRouter(string memory route, address[2] memory addressArr, uint[2] memory uintArr) external returns(bool success);

  function _callRouter(string memory route, address[3] memory addressArr, uint[3] memory uintArr) external returns(bool success);

  function extrenalRouterCall(string memory route, address[2] memory addressArr, uint[2] memory uintArr) external returns(bool success);

}

//========HYBRID CALL-BACK TO token.sol==========

abstract contract Token {
  function balanceOf(address account) external view virtual returns(uint256 data);

  function allowance(address owner, address spender) external view virtual returns(uint256 data);

  function updateTotalSupply(uint newTotalSupply) external virtual returns(bool success);

  function updateCurrentSupply(uint newCurrentSupply) external virtual returns(bool success);

  function updateJointSupply(uint newCurrentSupply) external virtual returns(bool success);

  function emitTransfer(address fromAddress, address toAddress, uint amount, bool affectTotalSupply) external virtual returns(bool success);

  function emitApproval(address fromAddress, address toAddress, uint amount) external virtual returns(bool success);

}

//============================================================================================
// MAIN CONTRACT 
//============================================================================================

contract Router is Ownable, IERC20 {

  using SafeMath
  for uint256;

  Token private token;
  address public tokenContract;

  mapping(string => address) public externalContracts; //for non-native functions

  //============== NATIVE FUNCTIONS START HERE ==================================================
  //These functions should never change when introducing a new version of a router.
  //Router is expected to constantly change, and the code should be written under 
  //the "NON-CORE FUNCTIONS TO BE CODED BELOW".

  function equals(string memory a, string memory b) internal view virtual returns(bool isEqual) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
  }

  function currentTokenContract() override external view virtual returns(address tokenContractAddress) {
    return tokenContract;
  }

  function getExternalContractAddress(string memory contractName) override external view virtual returns(address routerAddress) {
    return externalContracts[contractName];
  }

  //function is not needed if token address is hard-coded in a constructor
  function setNewTokenContract(address newTokenAddress) onlyOwner public virtual returns(bool success) {
    tokenContract = newTokenAddress;
    token = Token(newTokenAddress);
    return true;
  }

  function setNewExternalContract(string memory contractName, address newContractAddress) onlyOwner public virtual returns(bool success) {
    externalContracts[contractName] = newContractAddress;
    return true;
  }

  function callRouter(string memory route, address[2] memory addressArr, uint[2] memory uintArr) override external virtual returns(bool success) {
    require(msg.sender == tokenContract, "at: hybrid.sol | contract: Router | function: callRouter | message: Must be called by the registered Token contract");

    if (equals(route, "transfer")) {
      core_transfer(addressArr, uintArr);
    } else if (equals(route, "approve")) {
      core_approve(addressArr, uintArr);
    } else if (equals(route, "increaseAllowance")) {
      core_increaseAllowance(addressArr, uintArr);
    } else if (equals(route, "decreaseAllowance")) {
      core_decreaseAllowance(addressArr, uintArr);
    }
    return true;
  }

  function _callRouter(string memory route, address[3] memory addressArr, uint[3] memory uintArr) override external virtual returns(bool success) {

    require(msg.sender == tokenContract, "at: hybrid.sol | contract: Router | function: _callRouter | message: Must be called by the registered Token contract");

    if (equals(route, "transferFrom")) {
      core_transferFrom(addressArr, uintArr);
    }
    return true;
  }
  //============== NATIVE FUNCTIONS END HERE ==================================================

  //============== HYBRID CORE FUNCTIONS START HERE ===========================================

  function core_transfer(address[2] memory addressArr, uint[2] memory uintArr) private returns(bool success) {
    _transfer(addressArr, uintArr);
    return true;
  }

  function _transfer(address[2] memory addressArr, uint[2] memory uintArr) private returns(bool success) {
    address fromAddress = addressArr[0];
    address toAddress = addressArr[1];

    require(fromAddress != address(0), "at: hybrid.sol | contract: Core | function: _transfer | message: Sender cannot be address(0)");

    uint amount = uintArr[0];

    require(amount <= token.balanceOf(fromAddress), "at: hybrid.sol | contract: Core | function: _transfer | message: Insufficient amount");

    token.emitTransfer(fromAddress, toAddress, amount, true);
    return true;
  }

  function core_approve(address[2] memory addressArr, uint[2] memory uintArr) private returns(bool success) {
    _approve(addressArr, uintArr);
    return true;
  }

  function _approve(address[2] memory addressArr, uint[2] memory uintArr) private returns(bool success) {
    address owner = addressArr[0];
    address spender = addressArr[1];
    uint amount = uintArr[0];

    require(owner != address(0), "at: hybrid.sol | contract: Core | function: _approve | message: ERC20: approve from the zero address");
    require(spender != address(0), "at: hybrid.sol | contract: Core | function: _approve | message: ERC20: approve to the zero address");

    token.emitApproval(owner, spender, amount);

    return true;
  }

  function core_increaseAllowance(address[2] memory addressArr, uint[2] memory uintArr) private returns(bool success) {
    uint newAllowance = token.allowance(addressArr[0], addressArr[1]).add(uintArr[0]);
    uintArr[0] = newAllowance;
    _approve(addressArr, uintArr);
    return true;
  }

  function core_decreaseAllowance(address[2] memory addressArr, uint[2] memory uintArr) private returns(bool success) {
    uint newAllowance = token.allowance(addressArr[0], addressArr[1]).sub(uintArr[0], "at: hybrid.sol | contract: Core | function: decreaseAllowance | message: Decreases allowance below zero");
    uintArr[0] = newAllowance;
    _approve(addressArr, uintArr);
    return true;

  }

  function core_transferFrom(address[3] memory addressArr, uint[3] memory uintArr) private returns(bool success) {
    uint allowance = token.allowance(addressArr[1], addressArr[0]);
    require(allowance >= uintArr[0], "at: hybrid.sol | contract: Core | function: transferFrom | message: Insufficient amount");

    address[2] memory tmpAddresses1 = [addressArr[1], addressArr[2]];
    address[2] memory tmpAddresses2 = [addressArr[1], addressArr[0]];

    uint[2] memory tmpUint = [uintArr[0], uintArr[1]];

    _transfer(tmpAddresses1, tmpUint);

    tmpUint = [allowance.sub(uintArr[0]), uintArr[1]];
    _approve(tmpAddresses2, tmpUint);

    return true;
  }

  function core_mint(address[2] memory addressArr, uint[2] memory uintArr) private returns(bool success) {
    address fromAddress = address(0);
    address toAddress = addressArr[1];
    uint amount = uintArr[0];
    token.emitTransfer(fromAddress, toAddress, amount, true);
    return true;
  }

  function core_burn(address[2] memory addressArr, uint[2] memory uintArr) private returns(bool success) {
    address fromAddress = addressArr[0];
    address toAddress = address(0);
    uint amount = uintArr[0];
    token.emitTransfer(fromAddress, toAddress, amount, true);
    return true;
  }

  function core_updateTotalSupply(uint[2] memory uintArr) private returns(bool success) {
    uint amount = uintArr[0];
    token.updateTotalSupply(amount);
    return true;
  }

  function core_updateCurrentSupply(uint[2] memory uintArr) private returns(bool success) {
    uint amount = uintArr[0];
    token.updateCurrentSupply(amount);
    return true;
  }

  function core_updateJointSupply(uint[2] memory uintArr) private returns(bool success) {
    uint amount = uintArr[0];
    token.updateJointSupply(amount);
    return true;
  }

  //============== HYBRID CORE FUNCTIONS END HERE ===========================================

  //=============== NON-NATIVE ROUTES TO BE CODED BELOW =======================================
  // This code is a subject to a change, should we decide to alter anything.
  // We can also design another external router, possibilities are infinite.

  function extrenalRouterCall(string memory route, address[2] memory addressArr, uint[2] memory uintArr) override external virtual returns(bool success) {
    if (equals(route, "mint")) {
      require(externalContracts["mint"] == msg.sender, "at: hybrid.sol | contract: Router | function: extrenalRouterCall | message: Must be called by the registered external 'mint' contract");
      core_mint(addressArr, uintArr);
    } else if (equals(route, "burn")) {
      require(externalContracts["burn"] == msg.sender, "at: hybrid.sol | contract: Router | function: extrenalRouterCall | message: Must be called by the registered external 'burn' contract");
      core_burn(addressArr, uintArr);
    } else if (equals(route, "updateTotalSupply")) {
      require(externalContracts["updateTotalSupply"] == msg.sender, "at: hybrid.sol | contract: Router | function: extrenalRouterCall | message: Must be called by the registered external 'updateTotalSupply' contract");
      core_updateTotalSupply(uintArr);
    } else if (equals(route, "updateCurrentSupply")) {
      require(externalContracts["updateCurrentSupply"] == msg.sender, "at: hybrid.sol | contract: Router | function: extrenalRouterCall | message: Must be called by the registered external 'updateCurrentSupply' contract");
      core_updateCurrentSupply(uintArr);
    } else if (equals(route, "updateJointSupply")) {
      require(externalContracts["updateJointSupply"] == msg.sender, "at: hybrid.sol | contract: Router | function: extrenalRouterCall | message: Must be called by the registered external 'updateJointSupply' contract");
      core_updateJointSupply(uintArr);
    }

    return true;
  }

}
