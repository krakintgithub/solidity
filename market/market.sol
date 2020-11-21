 // SPDX-License-Identifier: MIT

 pragma solidity = 0.7 .4;

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

   function div(uint256 a, uint256 b) internal pure returns(uint256) {
     return div(a, b, "SafeMath: division by zero");
   }

   function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
     require(b > 0, errorMessage);
     uint256 c = a / b;
     // assert(a == b * c + a % b); // There is no case in which this doesn't hold

     return c;
   }

 }


 abstract contract Krakint{

   function transfer(address toAddress, uint256 amount) external virtual returns(bool);

 }

contract market {
    
using SafeMath for uint;    
    
    
uint private maxSell = 5000000000000000000000000; //we reserve 5 mil to a market
uint private krk2ethTotal = 0;
uint private eth2krkTotal = 0;
uint private circulatingKrk = 0;






//----------VIEWS START---------------------
function getAvailableTokens() public view virtual returns(uint available) {
    return maxSell.sub(circulatingKrk);       
}


function getKrkTotal() public view virtual returns(uint krkTotal){
    return krk2ethTotal;
}

function getEthTotal() public view virtual returns(uint ethTotal){
    return ethTotal;
}

function getCirculating() public view virtual returns(uint ethTotal){
    return circulatingKrk;
}
//----------VIEWS END-----------------------


     
 }


 }


 abstract contract Krakint{

   function transfer(address toAddress, uint256 amount) external virtual returns(bool);

 }

contract market {
    
using SafeMath for uint;    
    
    
uint private maxSell = 5000000000000000000000000; //we reserve 5 mil to a market
uint private krk2ethTotal = 0;
uint private eth2krkTotal = 0;
uint private circulatingKrk = 0;






//----------VIEWS START---------------------
function getAvailableTokens() public view virtual returns(uint available) {
    return maxSell.sub(circulatingKrk);       
}


function getKrkTotal() public view virtual returns(uint krkTotal){
    return krk2ethTotal;
}

function getEthTotal() public view virtual returns(uint ethTotal){
    return ethTotal;
}

function getCirculating() public view virtual returns(uint ethTotal){
    return circulatingKrk;
}
//----------VIEWS END-----------------------


     
 }
   }

   function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
     require(b > 0, errorMessage);
     uint256 c = a / b;
     // assert(a == b * c + a % b); // There is no case in which this doesn't hold

     return c;
   }

 }

 abstract contract ButtCoin {
   function transferFrom(address sender, address recipient, uint256 amount) external virtual returns(bool);

   function allowance(address owner, address spender) public view virtual returns(uint256);

   function balanceOf(address tokenOwner) public view virtual returns(uint balance);

   function transfer(address to, uint tokens) public virtual returns(bool success);

   function approve(address spender, uint tokens) public virtual returns(bool success);
 }

 abstract contract Krakint {

   function transfer(address toAddress, uint256 amount) external virtual returns(bool);

 }

 contract ButtSwap {
   mapping(address => uint256) public butts;

   using SafeMath
   for uint;
   uint private totalButts = 3355443199999981;
   uint private availableKrakints = 10000000000000000000000;
   ButtCoin private buttcoin;
   Krakint private krakint;
   address public contractAddress;
   address public owner;
   uint public krkInContract = 1000000000000000000000000; //to be reduced from 
   bool public isLive = true;

   address buttcoinAddress = address(0x5556d6a283fD18d71FD0c8b50D1211C5F842dBBc); //change before deployment
   address krakintAddress = address(0x7C131Ab459b874b82f19cdc1254fB66840D021B6); //change before deployment

   constructor() {
     contractAddress = address(this);
     owner = msg.sender;
     buttcoin = ButtCoin(buttcoinAddress);
     krakint = Krakint(krakintAddress);
   }

   function Step2(uint buttcoinAmount) public virtual returns(string memory message) {
     require(isLive, "Swap contract is stopped");

     require(buttcoin.balanceOf(msg.sender) >= buttcoinAmount, "Not enough allocated buttcoins");
     buttcoin.transferFrom(msg.sender, contractAddress, buttcoinAmount);
     butts[msg.sender] = butts[msg.sender].add(buttcoinAmount);

     uint amt2 = calculateKrakints(buttcoinAmount);
     require(krkInContract >= amt2, "Not enough krakints");

     krakint.transfer(msg.sender, amt2);

     krkInContract = krkInContract.sub(amt2);

     string memory mssg = "Done! Please wait for the Krakin't transfer to complete.";
     return mssg;
   }

   function calculateKrakints(uint buttcoins) private view returns(uint amount) {
     buttcoins = buttcoins.mul(10000000000000); //adds decimals
     uint ret = (buttcoins.mul(totalButts)).div(availableKrakints);
     return ret;
   }

   //we do not count the losses, so it can happen that some accounts will get butted!
   function recoverButtcoins() public virtual returns(bool success) {
     require(!isLive, "Contract must be stopped to get your butts back");
     require(butts[msg.sender] > 0, "You cannot recover zero buttcoins");
     buttcoin.transfer(msg.sender, butts[msg.sender]);
     butts[msg.sender] = 0;
     return true;
   }

   function stopSwap() public virtual {
     require(msg.sender == owner);
     require(isLive);
     isLive = false;
   }

 }
