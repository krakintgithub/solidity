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




/*
Keep a track of:
- total circulating Krk
- krkakint total earnings
- investors' total earnings

- depositedEth per user
- circulating KRK per user
- total fees paid per user

- overall burned KRK
- overall minted KRK
- overall deposited ETH
- overall fees paid
- overall investors' earnings

*/


contract Market {
    
using SafeMath for uint;    
    
uint private maxSell = 5000000000000000000000000; //we reserve 5 mil to this contract
uint private circulatingKrk = 0;
uint krakintTotalEthEarnings = 0; //can be subtracted from if taken from contract!
uint investorsCirculatingEthEarnings = 0; //can be subtracted from if taken from contract!
mapping(address => uint) private userEth;
mapping(address => uint) private circulatingUserKrk;
mapping(address => uint) private totalUserFees;
uint private totalBurnedKRK = 0;
uint private totalMintedKRK = 0;
uint private totalDepositedEth = 0;
uint private totalFeesPaid = 0;
uint private totalKrakintEarnings = 0; //cannot subtract from!
uint private totalInvestorsEarnings = 0; //cannot subtract from!
uint private totalDepositAfterFees = 0; //cannot subtract from!






function purchaseTokens() external payable {
    
    //get wei amount 
    require(msg.value>0, "Zero purchase, at purchaseTokens");
    uint weiAmount = msg.value;
    
    //project KRK return
    uint krks = getKrkReturn(weiAmount);
    require(circulatingKrk.add(krks)<=maxSell, "Purchase limit, at purchaseTokens, try smaller amounts or wait for buffer to clear.");

    //calculate fees
    uint fee = getFourPercent(weiAmount);
    uint krakintFee = fee.div(2);
    uint investorFee = fee.sub(krakintFee);
    uint afterFees = weiAmount.sub(fee);
    

    //update tables 
    circulatingKrk = circulatingKrk.add(krks);
    krakintTotalEthEarnings = krakintTotalEthEarnings.add(krakintFee);
    investorsCirculatingEthEarnings = investorsCirculatingEthEarnings.add(investorFee);
    
    userEth[msg.sender] = userEth[msg.sender].add(afterFees);
    circulatingUserKrk[msg.sender] = circulatingUserKrk[msg.sender].add(krks);
    totalUserFees[msg.sender] = totalUserFees[msg.sender].add(fee);
    
    //overall burned KRK - skipped!
    totalMintedKRK = totalMintedKRK.add(krks);
    totalDepositedEth = totalDepositedEth.add(weiAmount);
    totalFeesPaid = totalFeesPaid.add(fee);
    totalKrakintEarnings = totalKrakintEarnings.add(krakintFee);
    totalInvestorsEarnings = totalInvestorsEarnings.add(investorFee);
    totalDepositAfterFees = totalDepositAfterFees.add(afterFees);
 

    //mint tokens

}


//----------VIEWS START---------------------


function getKrkReturn(uint gweiAmount) public view virtual returns(uint krkAmount){

    uint fee_total = getFourPercent(gweiAmount);

    uint afterFee = gweiAmount.sub(fee_total);
    uint price = getPrice(circulatingKrk);
    uint krks = (afterFee.mul(1000000000000000000)).div(price);
    
    price = getPrice(circulatingKrk.add(krks));
    uint ret = (afterFee.mul(1000000000000000000)).div(price);
    return ret;
    
}


//-------PRIVATE VIEWS------------------------------------------------------


//----------VIEWS END-----------------------





//----------PRIVATE PURE START---------------------



//returns price per eth in gwei
function getPrice(uint x) private pure returns(uint retPrice) {

  //uint x = circulatingKrk;

  //stage 10
  //linear equation: y = 5.8579×10^-6 x - 19.2895
  //intercepts (4500000,7.07105) and (5000000,10)
  if (x >= 4500000000000000000000000) {
    return (((x).mul(58579)).div(10000000000)).sub(19289500000000000000);
  }

  //stage 9
  //linear equation: y = 3.8579×10^-6 x - 10.2895
  //intercepts (4000000,5.1421) and (5000000,9)
  if (x >= 4000000000000000000000000) {
    return (((x).mul(38579)).div(10000000000)).sub(10289500000000000000);
  }

  //stage 8
  //linear equation: y = 2.85792×10^-6 x - 6.28958
  //intercepts (3500000,3.713125) and (5000000,8)
  if (x >= 3500000000000000000000000) {
    return (((x).mul(6859)).div(2400000000)).sub(6289583333333333333);
  }

  //stage 7
  //linear equation: y = 2.19125×10^-6 x - 3.95625
  //intercepts (3000000,2.6175) and (5000000,7)
  if (x >= 3000000000000000000000000) {
    return (((x).mul(1753)).div(800000000)).sub(3956250000000000000);
  }

  //stage 6
  //linear equation: y = 1.69125×10^-6 x - 2.45625
  //intercepts (2500000,1.771875) and (5000000,6)
  if (x >= 2500000000000000000000000) {
    return (((x).mul(1353)).div(800000000)).sub(2456250000000000000);
  }

  //stage 5
  //linear equation: y = 1.29125×10^-6 x - 1.45625
  //intercepts (2000000,1.126251) and (5000000,5)
  if (x >= 2000000000000000000000000) {
    return (((x).mul(3873749)).div(3000000000000)).sub(1456248333333333333);
  }

  //stage 4
  //linear equation: y = 9.57917×10^-7 x - 0.789583
  //intercepts (1500000,0.647292) and (5000000,4)
  if (x >= 1500000000000000000000000) {
    return (((x).mul(838177)).div(875000000000)).sub(789582857142857142);
  }

  //stage 3
  //linear equation: y = 6.72202×10^-7 x - 0.361011
  //intercepts (1000000,0.311191) and (5000000,3)
  if (x >= 1000000000000000000000000) {
    return (((x).mul(2688809)).div(4000000000000)).sub(361011250000000000);
  }

  //stage 2
  //linear equation: y = 4.22202×10^-7 x - 0.111011
  //intercepts (500000,0.10009) and (5000000,2)
  if (x >= 500000000000000000000000) {
    return (((x).mul(189991)).div(450000000000)).sub(111011111111111111);
  }

  //stage 1
  //linear equation: y = 1.9998×10^-7 x + 0.0001
  //intercepts (0,0.0001) and (5000000,1)

    return (((x).mul(9999)).div(50000000000)).add(100000000000000);

}


function getFivePercent(uint number) private pure returns(uint fivePercent){
    uint ret = number.div(20);
    return ret;
}

function getTwoPercent(uint number) private pure returns(uint fivePercent){
    uint ret = number.div(50);
    return ret;
}

function getFourPercent(uint number) private pure returns(uint fivePercent){
    uint ret = number.div(25);
    return ret;
}

//----------PRIVATE PURE END---------------------


     
 }
