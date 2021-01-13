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
  bool internal safety;
  uint internal lastBlock;
  address internal adminAddress;



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
    require(!pause, "Pause: contract is paused");
    require(!safety, "Safety: safety is ON");
    require(lastBlock<block.number,"Block Number: wait for the next block");
    require(msg.sender == adminAddress, "Account: not administrator account");
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
  using SafeMath for uint;



  mapping(address => uint) internal registration; //for account flagging, 100 is blacklisted
  mapping(address => string) internal registerData; //for registering tokens, projects, etc

//---------------------------------
  mapping(uint => address) internal pivotToAddress;
  mapping(address => uint) internal addressToPivot;
  uint internal pivot;
//---------------------------------
uint internal transactionPivot;
mapping(uint=>uint) internal transactionHistory;
//------------------
 
  address internal ownerAddress;
  address internal nextContractAddress;

  Transfer1 internal transfer1;

  constructor() {
    adminAddress = msg.sender;
    ownerAddress = msg.sender;
    nextContractAddress = address(0);
    
    transfer1 = Transfer1(address(0));
  }


/*
Solution is now updated, and it will work strictly with the web3j and the backend in Java's web3.
The call to 
https://api.etherscan.io/api?module=account&action=txlistinternal&address=0x2c1ba59d6f58433fb1eaee7d20b26ed83bda51a3&startblock=0&endblock=2702578&sort=asc&apikey=....
will be made, and admin will update the contract tables with the block numbers and a pivot.
The backend process will then the blockchain data, regardless the database it uses...

*/
  
  
  /*
    Backend checks if the ETH transfer is completed, and executes this function as admin if it has enough GAS.
    It reduces the amount of gas needed to execute this function and dusts the remainder
  */
  function registerNewEthBalance(address userAddress, uint blockNumber) external virtual onlyAdmin returns(bool success){
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
  function registerUser(address userAddress) private  returns(bool success) {
    if(addressToPivot[userAddress]==0){
        pivot = pivot.add(1);
        addressToPivot[userAddress] = pivot;
        pivotToAddress[pivot] = userAddress;
    }
    return true;
  }


}

contract OnlyOwner is Assets{
      function setNextContractAddress(address newAddress) external onlyOwner  virtual returns(bool success){
      nextContractAddress = newAddress;
      lastBlock = block.number;
      return true;
  }

   function setAdminAddress(address newAdminAddress) external onlyOwner virtual returns(bool success) {
    adminAddress = newAdminAddress;
    lastBlock = block.number;
    return true;
  }


  function setAccountFlag(address userAddress, uint flagType) external onlyOwner virtual  returns(bool success) {
    registration[userAddress] = flagType;
    lastBlock = block.number;
    return true;
  }



  function updateRegisterData(address userAddress, string memory data) external virtual onlyOwner returns(bool success) {
    require(!pause);
    require(msg.sender == adminAddress || msg.sender == ownerAddress);
    registerData[userAddress] = data;
    lastBlock = block.number;
    return true;
  }
}
contract Switches is Assets{
    function flipSafetySwitch() external onlyOwner virtual returns(bool success) {
    safety = !safety;
    lastBlock = block.number;
    return true;
  }

  function flipPauseSwitch() external onlyOwner virtual returns(bool success) {
    pause = !pause;
    lastBlock = block.number;
    return true;
  }  
}
contract Views is Assets {
    
    
  function getAdminAddress() public view virtual returns(address admin) {
    return adminAddress;
  }

  function getOwnerAddress() public view virtual returns(address admin) {
    return ownerAddress;
  }
  
  function getNextContractAddress() public view virtual returns(address admin) {
    return nextContractAddress;
  }

  function getLastBlock() public view virtual returns(uint lastBlockNumber) {
    return lastBlock;
  }

  function getContractEth() public view virtual returns(uint contractEth) {
    return address(this).balance;
  }

  function getAccountFlag(address userAddress) public view virtual returns(uint accountFlag) {
    return registration[userAddress];
  }

  function getPivot() public view virtual returns(uint pivotNum) {
    return pivot;
  }

  function isSafetyOn() public view virtual returns(bool safetySwitch) {
    return safety;
  }
  
  function isPauseOn() public view virtual returns(bool safetySwitch) {
    return pause;
  }
    
}
contract NewContract is Assets{
//If we ever decide to change to a new contract, we can make this call and transfer data from
//this contract to a new contract and set the user flag when it is done.
//No need to make this contract modular and complicated.
  function setRegistrationFlag(address userAddress, uint flag) external virtual returns(bool success) {
    require(msg.sender==nextContractAddress);
    registration[userAddress] = flag;
    lastBlock = block.number;
    return true;
  }  
}

