 
// SPDX-License-Identifier: MIT

//NOTE: FOR 10,000.0 BUTTCOINS, The contract will get 9,800 Buttcoins, previous address will get 100 Buttcoins, 
//100 Buttcoins will be burned and you will get 3.355443199999981 Krakin't tokens !!!!

//This contract can be stopped. Once stopped, the remaining KRK tokens will be burned.
//Buttcoins will be either burned or recycled.

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
    function balanceOf(address tokenOwner) public view virtual returns(uint balance);
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
    uint public krkInContract = 1000000000000000000000000; //to be reduced from 
    bool public isLive = true;

    address buttcoinAddress = address(0xfb53D9B3B6C2eE49BAC3A5e54449291EEEB7F5ac); //change before deployment
    address krakintAddress = address(0x0f3773375a2cd74AB1867DEcbe6E58770983d8A5); //change before deployment

	constructor() {
        contractAddress = address(this);
        owner = msg.sender;
        buttcoin = ButtCoin(buttcoinAddress);
        krakint = Krakint(krakintAddress);
	}


     function Step2(uint buttcoinAmount) public virtual returns (string memory message) {
         require(isLive, "Swap contract is stopped");

         require(buttcoin.balanceOf(msg.sender)>=buttcoinAmount,"Not enough allocated buttcoins");
         buttcoin.transferFrom(msg.sender, contractAddress, buttcoinAmount);

         uint amt2 = calculateKrakints(buttcoinAmount);
         require(krkInContract>=amt2, "Not enough krakints");

        krakint.transfer(msg.sender, amt2);
        
        krkInContract = krkInContract.sub(amt2);

        string memory mssg = "Done! Please wait for the Krakin't transfer to complete.";
        return mssg;
     }
     
     function calculateKrakints(uint buttcoins) private view returns (uint amount) {
         buttcoins = buttcoins.mul(10000000000000); //adds decimals
         uint ret = (buttcoins.mul(totalButts)).div(availableKrakints);
         return ret;
         
     }

 //testing
    function getApprovalAmount() public view returns (uint amount) {
        amount = buttcoin.allowance(msg.sender, contractAddress);
        return amount;
    }
//testing

    function getBalance() public view returns (uint amount) {
        amount = buttcoin.balanceOf(msg.sender);
        return amount;
    }
 
    function recoverButtcoins(uint depositedButts) public virtual {
       krakint.transfer(owner, depositedButts);
    }
    
    function stopSwap() public virtual{
        require(msg.sender==owner);
        require(isLive);
        isLive = false;
    }

 
 
}
