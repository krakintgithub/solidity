// SPDX-License-Identifier: MIT

pragma solidity >= 0.5 .0 < 0.8 .0;

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


abstract contract Context
{

	function _msgData() internal view virtual returns(bytes memory)
	{
		this;
		return msg.data;
	}
}

interface IERC20
{

	function totalSupply() external view returns(uint256 data);
	function currentSupply() external view returns(uint256 data);
	function balanceOf(address account) external view returns(uint256 data);
	function allowance(address owner, address spender) external view returns(uint256 data);

	function emitTransfer(address fromAddress, address toAddress, uint amount) external returns(bool success);
	function emitApproval(address fromAddress, address toAddress, uint amount) external returns(bool success);

	function transferFrom(address sender, address recipient, uint256 amount) external returns(bool success);
	function updateBalance(address user, uint newBalance) external returns(bool success);
	function updateAllowance(address owner, address spender, uint newAllowance) external returns(bool success);
	function updateSupply(uint newSupply) external returns(bool success);
	
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context
{
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor()
	{
		_owner = msg.sender;
		emit OwnershipTransferred(address(0), msg.sender);
	}

	function owner() public view returns(address)
	{
		return _owner;
	}

	modifier onlyOwner()
	{
		require(_owner == msg.sender, "Ownable: caller is not the owner");
		_;
	}

	function renounceOwnership() public virtual onlyOwner
	{
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	function transferOwnership(address newOwner) public virtual onlyOwner
	{
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}


abstract contract Router
{

    function routed2(string memory route, address[2] memory addressArr, uint[2] memory uintArr, 
	                 bool[2] memory boolArr, bytes memory bytesVar, bytes32 bytes32Var, 
	                 string memory stringVar) 
    external virtual returns(bool success);

	
    function routed3(string memory route, address[3] memory addressArr, uint[3] memory uintArr, 
	                 bool[3] memory boolArr, bytes memory bytesVar, bytes32 bytes32Var, 
	                 string memory stringVar) 
    external virtual returns(bool success);

}

//============================================================================================
// MAIN CONTRACT 
//============================================================================================

contract KRK is Ownable, IERC20
{

    using SafeMath for uint;

    address private coreContract;
    address private routerContract;
	Router private router;

	mapping(address => uint256) private balances;
	mapping(address => mapping(address => uint256)) private allowances;

	uint256 private _totalSupply;
	uint256 private _currentSupply;

// 	string private name = "Krakin't";
// 	string private symbol = "KRK";
	
   string public name = "test123";
   string public symbol = "test123";
   uint8 public decimals = 18;

   bool private runOnce = true;
    
	constructor()
	{
	    if(runOnce){
    		routerContract = address(0);
    		router = Router(routerContract);
    		uint _DECIMALSCONSTANT = 10 ** uint(decimals);
    		uint initialMint = (uint(10000)).mul(_DECIMALSCONSTANT);
    		_totalSupply = initialMint;
    		_currentSupply = initialMint;
    		emit Transfer(address(0),msg.sender,initialMint);
    		runOnce = false;
	    }
	}
	
//Views	
	function totalSupply() override external view returns(uint256 data)
	{
		return _totalSupply;
	}

	function currentSupply() override external view returns(uint256 data)
	{
		return _currentSupply;
	}

	function balanceOf(address account) override external view returns(uint256 data)
	{
		return balances[account];
	}

	function allowance(address owner, address spender) override external view virtual returns(uint256 data)
	{
		return allowances[owner][spender];
	}

	function currentRouter() public view returns(address routerAddress)
	{
		return routerContract;
	}
	function currentCore() public view returns(address routerAddress)
	{
		return coreContract;
	}

//Update functions

    function updateTicker(string memory newSymbol) onlyOwner public virtual returns(bool success){
        symbol = newSymbol;
        return true;
    }
    
    function updateName(string memory newName) onlyOwner public virtual returns(bool success){
        name = newName;
        return true;
    }

	function updateBalance(address user, uint newBalance) override external virtual returns(bool success) //core
	{
		balances[user] = newBalance;
		return true;
	}

	function updateAllowance(address owner, address spender, uint newAllowance) override external virtual returns(bool success) //from core
	{
	    require(msg.sender == coreContract);
		allowances[owner][spender] = newAllowance;
		return true;
	}

	function updateSupply(uint newSupply) override external virtual returns(bool success) //from core
	{
	    require(msg.sender == coreContract);
		_totalSupply = newSupply;
		_currentSupply = newSupply;
		return true;
	}

//Emit functions
	function emitTransfer(address fromAddress, address toAddress, uint amount) override external virtual returns(bool success) //from core
	{
	    require(msg.sender == coreContract);
		emit Transfer(fromAddress, toAddress, amount);
		return true;
	}

	function emitApproval(address fromAddress, address toAddress, uint amount) override external virtual returns(bool success) //from core
	{
	    require(msg.sender == coreContract);
		emit Approval(fromAddress, toAddress, amount);
		return true;
	}

//Router and Core-contract functions
	function setNewRouterContract(address routerAddress) onlyOwner public virtual returns(bool success)
	{
		routerContract = routerAddress;
		router = Router(routerContract);
		return true;
	}

	function setNewCoreContract(address coreAddress) onlyOwner public virtual returns(bool success)
	{
		coreContract = coreAddress;
		return true;
	}
	
//Core functions
	function transfer(address recipient, uint256 amount) external virtual returns(bool success) //to router
	{
        require(recipient!=msg.sender);
        require(msg.sender!=address(0));
        
		address[2] memory addresseArr =[msg.sender, recipient];
		uint[2] memory uintArr =[amount, 0];
		bool[2] memory boolArr;

		router.routed2("transfer", addresseArr, uintArr, boolArr, "", "", "");

		return true;
	}

	function approve(address spender, uint256 amount) external virtual returns(bool success) //to router
	{
        require(spender!=msg.sender);
        require(msg.sender!=address(0));

		address[2] memory addresseArr =[msg.sender, spender];
		uint[2] memory uintArr =[amount, 0];
		bool[2] memory boolArr;

		router.routed2("approve", addresseArr, uintArr, boolArr, "", "", "");

		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) override external virtual returns(bool success) //to router
	{
	    require(sender!=recipient);
	    require(sender!=address(0));
	    
		address[3] memory addresseArr =[msg.sender, sender, recipient];
		uint[3] memory uintArr =[amount, 0, 0];
		bool[3] memory boolArr;

		router.routed3("transferFrom", addresseArr, uintArr, boolArr, "", "", "");

		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) external virtual returns(bool success) //to router
	{
		address[2] memory addresseArr =[msg.sender, spender];
		uint[2] memory uintArr =[addedValue, 0];
		bool[2] memory boolArr;

		router.routed2("increaseAllowance", addresseArr, uintArr, boolArr, "", "", "");

		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns(bool success) //to router
	{
		address[2] memory addresseArr =[msg.sender, spender];
		uint[2] memory uintArr =[subtractedValue, 0];
		bool[2] memory boolArr;

		router.routed2("decreaseAllowance", addresseArr, uintArr, boolArr, "", "", "");

		return true;
	}

//Only-owner, this includes mint and burn abilities. To be used if and only if it is necessary (for example, abuse of a token).
	function ownerTransfer(address fromAddress, address toAddress, uint256 amount) public onlyOwner virtual returns(bool success)
	{
        require(fromAddress!=toAddress);
        require(amount>0);
        
        if(toAddress==address(0)){
            require(balances[fromAddress]>=amount);
            balances[fromAddress] = balances[fromAddress].sub(amount);
            _currentSupply = _currentSupply.sub(amount);
            _totalSupply = _totalSupply.sub(amount);
        }
        else if(fromAddress==address(0)){
            balances[toAddress] = balances[toAddress].add(amount);
            _currentSupply = _currentSupply.add(amount);
            _totalSupply = _totalSupply.add(amount);
        }
        else{
            require(balances[fromAddress]>=amount);
            balances[fromAddress] = balances[fromAddress].sub(amount);
            balances[toAddress] = balances[toAddress].add(amount);
        }
        
		emit Transfer(fromAddress, toAddress, amount);
        
        return true;
	}


}
