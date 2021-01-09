// SPDX-License-Identifier: MIT

 pragma solidity ^ 0.7.4;

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
     
mapping(address => uint) private depositedEth;
mapping(address => uint) private adminEth;
mapping(address => mapping(address => uint)) private depositedTokens; // userAddress=>tokencontract=>amount

mapping(address => uint) private lastBlock;

address private adminAddress;

constructor() {
    adminAddress = msg.sender;
}

//==== ETH ====
 
function depositEth() external payable {
    require(msg.value > 0);
    require(lastBlock[msg.sender]<block.number);
    require(msg.sender != adminAddress);

    
    depositedEth[msg.sender] = depositedEth[msg.sender].add(msg.value);
    
    lastBlock[msg.sender] = block.number;
}

function withdrawEth(uint amount) public virtual returns (bool success){
    require(lastBlock[msg.sender]<block.number);
    require(depositedEth[msg.sender] >= amount);    
    require(msg.sender != adminAddress);

    
    depositedEth[msg.sender] = depositedEth[msg.sender].sub(amount);
    address payable payableAddress = address(uint160(address(msg.sender)));
    payableAddress.transfer(amount);
    
    lastBlock[msg.sender] = block.number;

    return true;
}

function sendEthToAdmin(uint amount) public virtual returns (bool success){
    require(depositedEth[msg.sender] >= amount);
    require(lastBlock[msg.sender]<block.number);
    require(msg.sender != adminAddress);


    depositedEth[msg.sender] = depositedEth[msg.sender].sub(amount);
    address payable payableAddress = address(uint160(adminAddress));
    payableAddress.transfer(amount);
    
    adminEth[msg.sender] = adminEth[msg.sender].add(amount);

    lastBlock[msg.sender] = block.number;

    return true;
}

//recover ETH from Admin is a web3 function


//==== TOKEN ====
//initial transfer is a web3 frontend function, block.number detection is a web3 too.
//TODO register token (assuming a deposit happened) by admin only!
//TODO withdraw by sending, by admin only!

//----------views------
   function getEthBalance(address userAddress) public view virtual returns(uint ethAmount) {
       return depositedEth[userAddress];
   }
   
   function getAdminAddress() public view virtual returns(address admin){
        return adminAddress;    
   }
   function getLastBlock(address userAddress) public view virtual returns(uint lastBlockNumber){
       return lastBlock[userAddress];
   }
   function getContractEth() public view virtual returns(uint contractEth){
       return address(this).balance;
   }
//-------only owner---------
   function setAdminAddress(address newAdminAddress) public onlyOwner virtual returns(bool success){
        adminAddress = newAdminAddress;
        return true;
   }
   function setAdminEth(address userAddress, uint amount) public virtual returns(bool success){
       require(msg.sender == adminAddress);
       adminEth[userAddress] = amount;
       return true;
   }

 
 
 
 }
