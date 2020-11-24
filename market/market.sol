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
    
uint private maxSell = 5000000000000000000000000; //we reserve 5 mil to this contract
uint private maxPrice = 10000000000000000000; //10 ETH for 1 KRK, our initial price is 0.00001 ETH for 1 KRK
uint private startPrice = 10000000000000; //our initial price is 0.00001 ETH for 1 KRK

mapping(address => uint) private ethAllowed; //how much ETH user can get from a contract, without extra reward
mapping(address => uint) private krkAllowed; //how much KRK user can use with the contract
uint private bonusEth = 0; //how much eth is allocated as a bonus
    
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

function getAllowedEth(address user) public view virtual returns(uint ethAmount){
    return ethAllowed[user];
}

function getAllowedKrk(address user) public view virtual returns(uint krkAmount){
    return krkAllowed[user];
}

function getPurchasePrice(uint krkAmt) public view virtual returns(uint priceOf){
    // uint sum = getFivePercent(krkAmt);
    // sum = sum.add(circulatingKrk.add(krkAmt));
    // require(sum<=maxSell);
    // uint price = krkAmt.mul(sum.div(500000));
    // return price;
}

//----------VIEWS END-----------------------





//----------PRIVATE PURE START---------------------

function getFivePercent(uint number) private pure returns(uint fivePercent){
    uint ret = number.div(20);
    return ret;
}

function getTwoPercent(uint number) private pure returns(uint fivePercent){
    uint ret = number.div(50);
    return ret;
}
//----------PRIVATE PURE END---------------------


     
 }
