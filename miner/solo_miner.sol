 // SPDX-License-Identifier: MIT

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

abstract contract Token {
    
	function balanceOf(address account) external view virtual returns(uint256 data);

    function totalSupply() external virtual view returns(uint256 data);
    
    function currentSupply() external virtual view returns(uint256 data);
    
}

abstract contract Router{
    
    function mint(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);

	function burn(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);
	
	function updateCurrentSupply(uint[2] memory uintArr) external virtual returns(bool success);
    
}


contract SoloMiner is Ownable{
    using SafeMath for uint;
    
    address public tokenContract;
	address public routerContract;
	Token private token;
	Router private router;
	
	function currentTokenContract() external view virtual returns(address tokenAddress) {
		return tokenContract;
	}

	function currentRouterContract() external view virtual returns(address routerAddress) {
		return routerContract;
	}

	function setNewTokenContract(address newTokenAddress) onlyOwner public virtual returns(bool success) {
		tokenContract = newTokenAddress;
		token = Token(newTokenAddress);
		return true;
	}

	function setNewRouterContract(address newRouterAddress) onlyOwner public virtual returns(bool success) {
		routerContract = newRouterAddress;
		return true;
	}

    function getGapSize() public view virtual returns (uint gapSize){
        return token.totalSupply().sub(token.currentSupply());
    }
    
    //TODO, save as a fraction!
    function getPurchasePower(uint amount) public view virtual returns (uint gapSize){
        return token.totalSupply().sub(token.currentSupply());
    }
	
    function burn(uint burnAmount) private returns (bool success){
        require (burnAmount <= token.currentSupply(), 
        "at: solo_miner.sol | contract: SoloMiner | function: burn | message: You cannot burn more tokens than the existing current supply");
        require (burnAmount <= token.balanceOf(msg.sender),
        "at: solo_miner.sol | contract: SoloMiner | function: burn | message: You are trying to burn more than what you own");
        
        address toAddress = address(0);
        address[2] memory addresseArr = [msg.sender, toAddress];
        uint[2] memory uintArr = [burnAmount, 0];
        router.burn(addresseArr, uintArr);

        return true;
    }
    
    
    function mint(uint mintAmount) private returns (bool success){
        address fromAddress = address(0);
        address[2] memory addresseArr = [fromAddress, msg.sender];
        uint[2] memory uintArr = [mintAmount, 0];
        router.mint(addresseArr, uintArr);

        return true;
    }
 
    
 

}
