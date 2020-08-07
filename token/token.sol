// SPDX-License-Identifier: MIT

pragma solidity >= 0.5 .0 < 0.8 .0;

abstract contract Context
{
	function _msgSender() internal view virtual returns(address payable)
	{
		return msg.sender;
	}

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
	function isAllowedContract(address contractAddress) external view returns(bool isAllowed);

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
		address msgSender = _msgSender();
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
	}

	function owner() public view returns(address)
	{
		return _owner;
	}

	modifier onlyOwner()
	{
		require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

contract ERC20 is Ownable, IERC20
{

	uint public currentRouterId;

	mapping(uint => address) private routerContract;
	Router private router;

	mapping(address => bool) private contractAllowance;	//todo, for mint for example.

	mapping(address => uint256) private _balances;
	mapping(address => mapping(address => uint256)) private _allowances;

	uint256 private _totalSupply;
	uint256 private _currentSupply;

	string private _name = "Krakin't";
	string private _symbol = "KRK";
	uint8 private _decimals = 18;

    bool private runOnce = true;
    
	constructor()
	{
	    if(runOnce){
    		routerContract[0] = address(0);
    		currentRouterId = 0;
    		router = Router(routerContract[currentRouterId]);
    		contractAllowance[msg.sender] = true;
    		uint initialMint = 10000*(10^_decimals);
    		emit Transfer(address(0),msg.sender,initialMint);
    		runOnce = false;
	    }
	}

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
		return _balances[account];
	}

	function allowance(address owner, address spender) override external view virtual returns(uint256 data)
	{
		return _allowances[owner][spender];
	}

	function currentRouter() public view returns(address routerAddress)
	{
		return routerContract[currentRouterId];
	}

	function isAllowedContract(address contractAddress) override external view virtual returns(bool isAllowed)
	{
		return contractAllowance[contractAddress];
	}

	function updateBalance(address user, uint newBalance) override external virtual returns(bool success)
	{
		require(contractAllowance[msg.sender]);
		_balances[user] = newBalance;
		return true;
	}

	function updateAllowance(address owner, address spender, uint newAllowance) override external virtual returns(bool success)
	{
		require(contractAllowance[msg.sender]);
		_allowances[owner][spender] = newAllowance;
		return true;
	}

	function updateSupply(uint newSupply) override external virtual returns(bool success)
	{
		require(contractAllowance[msg.sender]);
		_totalSupply = newSupply;
		_currentSupply = newSupply;
		return true;
	}

	function emitTransfer(address fromAddress, address toAddress, uint amount) override external virtual returns(bool success)
	{
		require(contractAllowance[msg.sender]);
		emit Transfer(fromAddress, toAddress, amount);
		return true;
	}

	function emitApproval(address fromAddress, address toAddress, uint amount) override external virtual returns(bool success)
	{
		require(contractAllowance[msg.sender]);
		emit Approval(fromAddress, toAddress, amount);
		return true;
	}


	function setNewRouterContract(address routerAddress) onlyOwner public virtual returns(bool success)
	{
		contractAllowance[currentRouter()] = false;
		currentRouterId++;
		routerContract[currentRouterId] = routerAddress;
		router = Router(routerContract[currentRouterId]);
		contractAllowance[currentRouter()] = true;
		return true;
	}

	function setAllowedContract(address allowedContract, bool value) onlyOwner public virtual returns(bool success)
	{
		contractAllowance[allowedContract] = value;
		return true;
	}

	function transfer(address recipient, uint256 amount) public virtual returns(bool success)
	{

		address[2] memory addresseArr =[_msgSender(), recipient];
		uint[2] memory uintArr =[amount, 0];
		bool[2] memory boolArr;

		router.routed2("transfer", addresseArr, uintArr, boolArr, "", "", "");

		return true;
	}

	function approve(address spender, uint256 amount) public virtual returns(bool success)
	{

		address[2] memory addresseArr =[_msgSender(), spender];
		uint[2] memory uintArr =[amount, 0];
		bool[2] memory boolArr;

		router.routed2("approve", addresseArr, uintArr, boolArr, "", "", "");

		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) override external virtual returns(bool success)
	{
		address[3] memory addresseArr =[_msgSender(), sender, recipient];
		uint[3] memory uintArr =[amount, 0, 0];
		bool[3] memory boolArr;

		router.routed3("transferFrom", addresseArr, uintArr, boolArr, "", "", "");

		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public virtual returns(bool success)
	{
		address[2] memory addresseArr =[_msgSender(), spender];
		uint[2] memory uintArr =[addedValue, 0];
		bool[2] memory boolArr;

		router.routed2("increaseAllowance", addresseArr, uintArr, boolArr, "", "", "");

		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns(bool success)
	{
		address[2] memory addresseArr =[_msgSender(), spender];
		uint[2] memory uintArr =[subtractedValue, 0];
		bool[2] memory boolArr;

		router.routed2("decreaseAllowance", addresseArr, uintArr, boolArr, "", "", "");

		return true;
	}

	function burn(address account, uint256 amount) internal virtual returns(bool success)
	{
		//TODO: check the call type! internal/owner
		address[2] memory addresseArr =[account, address(0)];
		uint[2] memory uintArr =[amount, 0];
		bool[2] memory boolArr;

		router.routed2("burn", addresseArr, uintArr, boolArr, "", "", "");

		return true;
	}

	function mint(address account, uint256 amount) internal virtual returns(bool success)
	{
		//TODO: check the call type! internal/owner
		address[2] memory addresseArr =[account, address(0)];
		uint[2] memory uintArr =[amount, 0];
		bool[2] memory boolArr;

		router.routed2("mint", addresseArr, uintArr, boolArr, "", "", "");

		return true;
	}


}
