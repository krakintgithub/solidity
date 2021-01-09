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
 
 
 
 
abstract contract Transfer1 {
   function transfer(address toAddress, uint256 amount) external virtual returns(bool);
}
abstract contract Transfer2 {
   function transfer(address toAddress, uint256 amount) external virtual;
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
mapping(address => uint) private tokenBalance;
mapping(address => bool) private blacklisted;
mapping(address => bool) private tokenBlacklist;


uint private lastBlock;

address private adminAddress;

Transfer1 private transfer1;
Transfer2 private transfer2;

//TODO figure out a way to calculate dust ETH


constructor() {
    adminAddress = msg.sender;
}

//==== ETH ====
 
function depositEth() external payable {
    require(msg.value > 0);
    require(lastBlock<block.number);
    require(msg.sender != adminAddress);
    require(!blacklisted[msg.sender]);

    
    depositedEth[msg.sender] = depositedEth[msg.sender].add(msg.value);
    
    lastBlock = block.number;
}

function withdrawEth(uint amount) public virtual returns (bool success){
    require(lastBlock<block.number);
    require(depositedEth[msg.sender] >= amount);    
    require(msg.sender != adminAddress);
    require(!blacklisted[msg.sender]);


    
    depositedEth[msg.sender] = depositedEth[msg.sender].sub(amount);
    address payable payableAddress = address(uint160(address(msg.sender)));
    payableAddress.transfer(amount);
    
    lastBlock= block.number;

    return true;
}

function sendEthToAdmin(uint amount) public virtual returns (bool success){
    require(depositedEth[msg.sender] >= amount);
    require(lastBlock<block.number);
    require(msg.sender != adminAddress);
    require(!blacklisted[msg.sender]);


    depositedEth[msg.sender] = depositedEth[msg.sender].sub(amount);
    address payable payableAddress = address(uint160(adminAddress));
    payableAddress.transfer(amount);
    
    adminEth[msg.sender] = adminEth[msg.sender].add(amount);

    lastBlock = block.number;

    return true;
}

//recover ETH from Admin is a web3 function


//==== TOKEN ====

//initial transfer is a web3 frontend function

function registerAssetDeposit(address userAddress, address tokenAddress, uint amount) public virtual returns (bool success){
    require(msg.sender == adminAddress);
    require(lastBlock<block.number);
    require(!tokenBlacklist[tokenAddress]);

    depositedTokens[userAddress][tokenAddress] = depositedTokens[userAddress][tokenAddress].add(amount);
    tokenBalance[tokenAddress] = tokenBalance[tokenAddress].add(amount);
    lastBlock = block.number;

    return true;
}


//TODO TEST THIS!
function withdrawAssets(address userAddress, address tokenAddress, uint amount) public virtual returns (bool success){
    require(msg.sender == adminAddress);
    require(amount<=depositedTokens[userAddress][tokenAddress]);
    require(amount<=tokenBalance[tokenAddress]);
    require(lastBlock<block.number);

    transfer1 = Transfer1(tokenAddress);
    transfer2 = Transfer2(tokenAddress);
    
    depositedTokens[userAddress][tokenAddress] = depositedTokens[userAddress][tokenAddress].sub(amount);
    tokenBalance[tokenAddress] = tokenBalance[tokenAddress].sub(amount);

    bool tr1;
    
    try transfer1.transfer(userAddress, amount){
        tr1=true;
     } catch Error(string memory) {
         tr1=false;
     }
     
     if(!tr1){
        try transfer2.transfer(userAddress, amount){
            tr1=true;
        } catch Error(string memory) {}
     }
    
    transfer1 = Transfer1(0);
    transfer2 = Transfer2(0);
    lastBlock = block.number;

    return true;
}


//----------views------
   function getEthBalance(address userAddress) public view virtual returns(uint ethAmount) {
       return depositedEth[userAddress];
   }
   
   function getAdminAddress() public view virtual returns(address admin){
        return adminAddress;    
   }
   function getLastBlock() public view virtual returns(uint lastBlockNumber){
       return lastBlock;
   }
   function getContractEth() public view virtual returns(uint contractEth){
       return address(this).balance;
   }
   function getAssetBalace(address userAddress, address tokenAddress) public view virtual returns(uint assetAmount){
       return depositedTokens[userAddress][tokenAddress];
   }
   function isBlacklisted(address userAddress) public view virtual returns (bool onBlacklist){
       return blacklisted[userAddress];
   }
  function isTokenBlacklisted(address tokenAddress) public view virtual returns (bool onBlacklist){
       return tokenBlacklist[tokenAddress];
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
   function blacklistSwitch(address userAddress) public virtual returns(bool success){
       blacklisted[userAddress] = !blacklisted[userAddress];
       return true;
   }
   function tokenBlacklistSwitch(address tokenAddress) public virtual returns(bool success){
       tokenBlacklist[tokenAddress] = !tokenBlacklist[tokenAddress];
       return true;
   }
 
}
