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


//******************
//returns price per eth in gwei
function getPrice() public view returns(uint retPrice) {

  uint x = circulatingKrk;

  //stage 10
  //linear equation: y = 5.8579×10^-6 x - 19.2895
  if (x > 4500000000000000000000000) {
    require((x).mul(58579) > 192895, "Error in getPrice, stage 10, amount too small");
    return (((x).mul(58579)).sub(192895000000)).mul(100000000);
  }

  //stage 9
  //linear equation: y = 3.8579×10^-6 x - 10.2895
  if (x > 4000000000000000000000000) {
    require((x).mul(38579) > 102895, "Error in getPrice, stage 9, amount too small");
    return (((x).mul(38579)).sub(102895000000)).mul(100000000);
  }

  //stage 8
  //linear equation: y = 2.85792×10^-6 x - 6.28958
  if (x > 3500000000000000000000000) {
    require((x).mul(285792) > 628958000000, "Error in getPrice, stage 8, amount too small");
    return (((x).mul(285792)).sub(628958000000)).mul(10000000);
  }

  //stage 7
  //linear equation: y = 2.19125×10^-6 x - 3.95625
  if (x > 3000000000000000000000000) {
    require((x).mul(219125) > 395625000000, "Error in getPrice, stage 7, amount too small");
    return (((x).mul(219125)).sub(395625000000)).mul(10000000);
  }

  //stage 6
  //linear equation: y = 1.69125×10^-6 x - 2.45625
  if (x > 2500000000000000000000000) {
    require((x).mul(169125) > 245625000000, "Error in getPrice, stage 6, amount too small");
    return (((x).mul(169125)).sub(245625000000)).mul(10000000);
  }

  //stage 5
  //linear equation: y = 1.29125×10^-6 x - 1.45625
  if (x > 2000000000000000000000000) {
    require((x).mul(129125) > 145625000000, "Error in getPrice, stage 5, amount too small");
    return (((x).mul(129125)).sub(145625000000)).mul(10000000);
  }

  //stage 4
  //linear equation: y = 9.57917×10^-7 x - 0.789583
  if (x > 1500000000000000000000000) {
    require((x).mul(957917) > 7895830000000, "Error in getPrice, stage 4, amount too small");
    return (((x).mul(957917)).sub(7895830000000)).mul(1000000);
  }

  //stage 3
  //linear equation: y = 6.72202×10^-7 x - 0.361011
  if (x > 1000000000000000000000000) {
    require((x).mul(6722020) > 3610110000000, "Error in getPrice, stage 3, amount too small");
    return (((x).mul(6722020)).sub(3610110000000)).mul(100000);
  }

  //stage 2
  //linear equation: y = 4.22202×10^-7 x - 0.111011
  if (x > 500000000000000000000000) {
    require((x).mul(4222020) > 1110110000000, "Error in getPrice, stage 2, amount too small");
    return (((x).mul(4222020)).sub(1110110000000)).mul(100000);
  }

  //stage 1
  //linear equation: y = 1.9998×10^-7 x + 0.0001
  require((x).mul(1999800) > 100, "Error in getPrice, stage 1, amount too small");
  return (((x).mul(1999800)).sub(100)).mul(100000);

}
//******************






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
