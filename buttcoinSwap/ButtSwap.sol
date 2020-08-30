 // SPDX-License-Identifier: MIT

 //NOTE: FOR 10,000.0 BUTTCOINS, The contract will get 9,800 Buttcoins, previous address will get 100 Buttcoins, 
 //100 Buttcoins will be burned and you will get 3.355443199999981 Krakin't tokens !!!!
 //The contract will keep a track of 10,000.0 Buttcoins, and you will get 9,800 back once the swap is stopped.
 //At least one account will get butted since the % of burn is not calculated, and the contract won't have enough butts to give back.
 //Sooner you get your buttcoins, lower are the chances of getting butted!
 //Remaining buttcoins will rest in peace on the address of this contract, as a monument to all of the buttcoins that were burned and that may have fallen...

 //This contract can be stopped. Once stopped, the remaining KRK tokens will be burned from a contract.

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
   mapping(address => uint256) internal butts;

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

   address buttcoinAddress = address(0x38b810BD9Bef140F3039AC78D68337705aF09259); //change before deployment
   address krakintAddress = address(0xf61cc2A22D2Ee34e2eF7802EdCc5268cfB1c4A71); //change before deployment

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
