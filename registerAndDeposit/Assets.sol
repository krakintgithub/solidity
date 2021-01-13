/*
This contract aids the token deposit and registering with the Krakin't exchange.
Data already exists on a block-chain and therefore, it has to be accessed via API calls.
The Administrator account is used to send tokens to and out of the exchange.
Since the Administrator account needs GAS, the users need to deposit the Ethereum necessary to run this contract.
We are also collecting the information from the block-chain and writing it inside the contract.
This way, we can always transfer this data into new databases and make the last solution as decentralized as possible.
There are 3 primary accounts associated with this contract:
- The owner account
- The admin account
- The external contract account

The purpose of the owner is the general maintenance of the contract.
The purpose of admin is to connect to an outside wallet to do the main contract interaction.
The purpose of the external contract is to act as an admin, and as a decentralized solution while standing in a middle.
*/

// SPDX-License-Identifier: MIT

pragma solidity ^ 0.7 .4;

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
  address internal _owner;
  bool internal pause;
  uint internal lastBlock;
  address internal adminAddress;
  address internal externalContract;

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

  modifier onlyAdmin() {
    require(!pause, "OnlyAdmin: pause is ON");
    require(lastBlock < block.number, "OnlyAdmin: wait for the next block");
    require(msg.sender == adminAddress || msg.sender == externalContract, "OnlyAdmin: not administrator or external contract account");
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

abstract contract Transfer1 {
  function transfer(address toAddress, uint256 amount) external virtual;

  function transferFrom(address sender, address recipient, uint256 amount) external virtual;
}

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

contract Assets is Ownable {
  using SafeMath
  for uint;

  mapping(address => uint) internal registration; //for account flagging, 100 is blacklisted
  mapping(address => string) internal registerData; //for registering tokens, projects, etc

  //---------------------------------
  mapping(uint => address) internal pivotToAddress;
  mapping(address => uint) internal addressToPivot;
  uint internal pivot;
  //---------------------------------
  uint internal transactionPivot;
  mapping(uint => uint) internal transactionHistory;
  //------------------

  address internal ownerAddress;

  Transfer1 internal transfer1;

  constructor() {
    adminAddress = msg.sender;
    ownerAddress = msg.sender;
    externalContract = address(0);
    transfer1 = Transfer1(address(0));
  }

  //The admin must make this call!
  function registerNewEthBalance(address userAddress, uint blockNumber) external virtual onlyAdmin returns(bool success) {
    registerUser(userAddress);
    transactionHistory[transactionPivot] = blockNumber;
    transactionPivot = transactionPivot.add(1);
    lastBlock = block.number;
    return true;
  }

  //recover ETH from Admin is a web3 function, not a contract, then another call to registerNewEthBalance is made

  //==== TOKEN ====

  function registerNewTokenBalance(address userAddress, uint blockNumber) external virtual onlyAdmin returns(bool success) {
    registerUser(userAddress);

    transactionHistory[transactionPivot] = blockNumber;
    transactionPivot = transactionPivot.add(1);

    transfer1 = Transfer1(0);

    lastBlock = block.number;
    return true;
  }

  //The admin must make this call!
  function withdrawTokens(address userAddress, address tokenAddress, uint amount) external virtual onlyAdmin returns(bool success) {

    transfer1 = Transfer1(tokenAddress);

    transactionHistory[transactionPivot] = block.number;
    transactionPivot = transactionPivot.add(1);

    transfer1.transfer(userAddress, amount);
    transfer1 = Transfer1(0);

    lastBlock = block.number;

    return true;
  }

  //---------helpers-------
  function registerUser(address userAddress) private returns(bool success) {
    if (addressToPivot[userAddress] == 0) {
      pivot = pivot.add(1);
      addressToPivot[userAddress] = pivot;
      pivotToAddress[pivot] = userAddress;
    }
    return true;
  }

}

contract OnlyOwner is Assets {

  function setAdminAddress(address newAdminAddress) external onlyOwner virtual returns(bool success) {
    adminAddress = newAdminAddress;
    lastBlock = block.number;
    return true;
  }

  function setExternalContractAddress(address newContract) external onlyOwner virtual returns(bool success) {
    externalContract = newContract;
    lastBlock = block.number;
    return true;
  }

  function setAccountFlag(address userAddress, uint flagType) external onlyOwner virtual returns(bool success) {
    registration[userAddress] = flagType;
    lastBlock = block.number;
    return true;
  }

  function updateRegisterData(address userAddress, string memory data) external virtual onlyOwner returns(bool success) {
    registerData[userAddress] = data;
    lastBlock = block.number;
    return true;
  }
}
contract Switches is Assets {

  function flipPauseSwitch() external onlyOwner virtual returns(bool success) {
    pause = !pause;
    lastBlock = block.number;
    return true;
  }
}
contract Views is Assets {

  function getExternalContractAddress() public view virtual returns(address externalContract) {
    return externalContract;
  }

  function getAdminAddress() public view virtual returns(address admin) {
    return adminAddress;
  }

  function getOwnerAddress() public view virtual returns(address admin) {
    return ownerAddress;
  }

  function getLastBlock() public view virtual returns(uint lastBlockNumber) {
    return lastBlock;
  }

  function getBlockNumber() public view virtual returns(uint blockNumber) {
    return block.number;
  }

  function getContractEth() public view virtual returns(uint contractEth) {
    return address(this).balance;
  }

  function getAccountFlag(address userAddress) public view virtual returns(uint accountFlag) {
    return registration[userAddress];
  }

  function getRegisterData(address userAddress) public view virtual returns(string memory data) {
    return registerData[userAddress];
  }

  function isPauseOn() public view virtual returns(bool safetySwitch) {
    return pause;
  }

  function getPivot() public view virtual returns(uint pivot) {
    return pivot;
  }

  function getTransactionPivot() public view virtual returns(uint pivot) {
    return transactionPivot;
  }

  function getAddressFromPivot(uint pivot) public view virtual returns(address userAddress) {
    return pivotToAddress[pivot];
  }

  function getPivotFromAddress(address userAddress) public view virtual returns(uint pivot) {
    return addressToPivot[userAddress];
  }

  function getTransactionFromPivot(uint pivot) public view virtual returns(uint transaction) {
    return transactionHistory[pivot];
  }

}
