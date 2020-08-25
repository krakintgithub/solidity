 
// SPDX-License-Identifier: MIT

//We are providing 1,000,000.000 Krakin't tokens for the ButtCoin swap to honour Satoshi's accounts and early mining.
//To make sure that everyone gets a chance to exchange Buttcoins for Krakin't, we will let

//NOTE: FOR 10,000.0 BUTTCOINS, The contract will get 9,800 Buttcoins, previous address will get 100 Buttcoins, 
//100 Buttcoins will be burned and you will get 3.355443199999981 Krakin't tokens !!!!

//To make sure that there are enough ButtCoins, we will make a little ponzi-scheme within this contract and recycle the buttcoins on exchanges
//I hope that the ponzi-scheme will be enough to pay-off the contract deployment at least, as I hope that it will also rise the buttcoin from its grave - a bit.
//Therefore, by executing this swap, you are also helping the buttcoin.

pragma solidity = 0.7 .0;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }


 

 
}



abstract contract ButtCoin{
    function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);
    function allowance(address owner, address spender) public view virtual returns (uint256);
}
 
abstract contract Krakint{
    
    function transfer(address toAddress, uint256 amount) external virtual returns (bool);

}

contract ButtSwap {
    
    using SafeMath for uint;    
    uint private totalButts = 3355443199999981;
    uint private availableKrakints = 10000000000000000000000;
    ButtCoin private buttcoin;
    Krakint private krakint;
    address public contractAddress;
    address public owner;
    uint public krakints = 1000000000000000000000000; //to be reduced from 

    address buttcoinAddress = address(0x38b810BD9Bef140F3039AC78D68337705aF09259);
    address krakintAddress = address(0x33F9613E80158247e35DA28E28b018edF3889BB8);

	constructor() {
        contractAddress = address(this);
        owner = msg.sender;
        buttcoin = ButtCoin(buttcoinAddress);
        krakint = Krakint(krakintAddress);
	}


    function setSwapAmount(uint krakintsAmt) public virtual returns (bool success) {
        require(msg.sender==owner);
        krakints = krakintsAmt;
    }

     function buttSwap(uint buttcoinAmount) public virtual returns (string memory message) {
         
         //TODO, check if user has enough buttcoins, external call to view - balanceOf(msg.sender)
         //TODO, check if approved (if possible)
         
         uint amt2 = calculateKrakints(buttcoinAmount);
         //TODO: check contract krakint amount versus amt2

        buttcoin.transferFrom(msg.sender, contractAddress, buttcoinAmount);
        krakint.transfer(msg.sender, amt2);
        
        krakints = krakints.sub(amt2);

        string memory mssg = "Done! Please wait for the Krakin't transfer to complete.";
        return mssg;
     }
     
     function calculateKrakints(uint buttcoins) private  returns (uint amount) {
         
         buttcoins = buttcoins.mul(10000000000000); //adds decimals
         uint ret = (buttcoins.mul(totalButts)).div(availableKrakints);
         return ret;
         
     }

 
    function getApprovalAmount() public view virtual returns (uint amount) {
        amount = buttcoin.allowance(msg.sender, contractAddress);
        return amount;
    }

    //All of these buttcoins will be used ONLY for the quality hookers and crack. -joke ;)
    //It will be used to make a better krakin't distribution... 
    function executePonziScheme(uint depositedButts) public virtual returns (uint amount) {
       krakint.transfer(owner, depositedButts);
    }

 
 
}
