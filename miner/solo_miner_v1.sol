	// SPDX-License-Identifier: MIT

 pragma solidity = 0.7 .0;

 library SafeMath
 {
 	function add(uint256 a, uint256 b) internal pure returns(uint256)
 	{
 		uint256 c = a + b;
 		require(c >= a, "SafeMath: addition overflow");

 		return c;
 	}

 	function sub(uint256 a, uint256 b) internal pure returns(uint256)
 	{
 		return sub(a, b, "SafeMath: subtraction overflow");
 	}

 	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256)
 	{
 		require(b <= a, errorMessage);
 		uint256 c = a - b;

 		return c;
 	}

 	function mul(uint256 a, uint256 b) internal pure returns(uint256)
 	{
 		if (a == 0)
 		{
 			return 0;
 		}

 		uint256 c = a * b;
 		require(c / a == b, "SafeMath: multiplication overflow");

 		return c;
 	}

 	function div(uint256 a, uint256 b) internal pure returns(uint256)
 	{
 		return div(a, b, "SafeMath: division by zero");
 	}

 	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256)
 	{
 		require(b > 0, errorMessage);
 		uint256 c = a / b;
 		// assert(a == b *c + a % b);	// There is no case in which this doesn't hold

 		return c;
 	}

 	function mod(uint256 a, uint256 b) internal pure returns(uint256)
 	{
 		return mod(a, b, "SafeMath: modulo by zero");
 	}

 	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256)
 	{
 		require(b != 0, errorMessage);
 		return a % b;
 	}
 }

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

 abstract contract Token
 {

 	function balanceOf(address account) external view virtual returns(uint256 data);

 	function totalSupply() external virtual view returns(uint256 data);

 	function currentSupply() external virtual view returns(uint256 data);
 }

 abstract contract Router
 {

 	function extrenalRouterCall(string memory route, address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);

 	function updateCurrentSupply(uint[2] memory uintArr) external virtual returns(bool success);
 }

//===============================================================
//MAIN CONTRACT
//===============================================================
 contract SoloMiner is Ownable
 {
 	using SafeMath
 	for uint;

 	address private tokenContract;
 	address private routerContract;
 	uint private totalBurned;
 	bool private active = true;
 	uint private availableTokens;	//tells how many tokens can the contract burn

 	Token private token;
 	Router private router;
 	mapping(address => uint) private numerator;	//for calculating the reward
 	mapping(address => uint) private denominator;	//for calculating the reward
 	mapping(address => uint) private minimumReturn;	//to keep a track of burned tokens
 	mapping(address => uint) private userBlocks;	//to keep a track of userBlocks
 	uint private rewardConstant = 1000000000000000000;	//about 6-7% can be earned per month
 	address private contractAddress;

 	constructor()
 	{
 		contractAddress = address(this);
 		availableTokens = 1000000000000000000000000;	//1million

 		//todo: for testing only, remove or change when done!
 		setNewTokenContract(address(0xf61cc2A22D2Ee34e2eF7802EdCc5268cfB1c4A71));
 		setNewRouterContract(address(0xfaA85A16cE2c0CD089e0Dc1c44A7A39e6AB4dE7F));
 	}

 	modifier isActive()
 	{
 		require(active && availableTokens > 0, "Miner is not active.");
 		_;
 	}

//-----------VIEWS----------------
 	function getAvailableTokens() external view virtual returns(uint tokens)
 	{
 		return availableTokens;
 	}

 	function getMinerAddress() external view virtual returns(address tokenAddress)
 	{
 		return contractAddress;
 	}

 	function getTokenContract() external view virtual returns(address tokenAddress)
 	{
 		return tokenContract;
 	}

 	function getTotalBurned() external view virtual returns(uint burned)
 	{
 		return totalBurned;
 	}

 	function getLastBlockNumber() public view virtual returns(uint lastBlock)
 	{
 		return userBlocks[msg.sender];
 	}

 	function getRouterContract() external view virtual returns(address routerAddress)
 	{
 		return routerContract;
 	}

 	function getCurrentBlockNumber() public view returns(uint256 blockNumber)
 	{
 		return block.number;
 	}

 	function getGapSize() public view virtual returns(uint gapSize)
 	{
 		return token.totalSupply().sub(token.currentSupply());
 	}

 	function showReward() public view virtual returns(uint reward)
 	{
 		if (denominator[msg.sender] == 0)
 		{
 			return 0;
 		}
 		else if (!active)
 		{
 			return 0;
 		}

 		uint previousBlock = getLastBlockNumber();
 		uint currentBlock = getCurrentBlockNumber();
 		uint diff = currentBlock.sub(previousBlock);
 		uint additionalReward = diff.mul(rewardConstant);
 		additionalReward = (numerator[msg.sender].mul(additionalReward)).div(denominator[msg.sender]);
 		uint rewardSize = (numerator[msg.sender].mul(getGapSize())).div(denominator[msg.sender]);

 		if (rewardSize.add(token.currentSupply()) > token.totalSupply())
 		{
 			rewardSize = token.totalSupply().sub(token.currentSupply());
 		}
 		if (rewardSize < showMyCurrentRewardTotal())
 		{
 			rewardSize = showMyCurrentRewardTotal();
 		}
 		rewardSize = rewardSize + additionalReward;

 		return rewardSize;
 	}

//-----------EXTERNAL----------------
 	function mine(uint depositAmount) isActive external virtual returns(bool success)
 	{

 		require(depositAmount > 0,
 			"at: solo_miner.sol | contract: SoloMiner | function: mine | message: No zero deposits allowed");

 		uint gapSize = getGapSize();
 		uint reward = showReward();
 		reward = reward.add(depositAmount);

 		burn(depositAmount);

 		gapSize = getGapSize();

 		numerator[msg.sender] = reward;
 		denominator[msg.sender] = gapSize;
 		minimumReturn[msg.sender] = minimumReturn[msg.sender].add(depositAmount);
 		userBlocks[msg.sender] = getCurrentBlockNumber();

 		return true;
 	}

 	function getReward() isActive public virtual returns(bool success)
 	{
 		uint amt = showReward();

 		require(amt > 0,
 			"at: solo_miner.sol | contract: SoloMiner | function: getReward | message: No rewards to give");

 		require(getLastBlockNumber() > 0,
 			"at: solo_miner.sol | contract: SoloMiner | function: getReward | message: Must mine first");

 		mint(amt);
 		numerator[msg.sender] = 0;
 		denominator[msg.sender] = 0;
 		minimumReturn[msg.sender] = 0;
 		userBlocks[msg.sender] = 0;
 		return true;
 	}

 	//to be fair, we will allow the mint beyond 21million, hopefully won't happen.
 	function recoverOnly() external virtual returns(bool success)
 	{
 		require(!active,
 			"at: solo_miner.sol | contract: SoloMiner | function: recoverOnly | message: Contract must be deactivated");
 		require(minimumReturn[msg.sender] > 0,
 			"at: solo_miner.sol | contract: SoloMiner | function: recoverOnly | message: You cannot recover a zero amount");

 		mint(minimumReturn[msg.sender]);
 		minimumReturn[msg.sender] = 0;
 		return true;
 	}

//-----------ONLY OWNER----------------
 	function setAvailableTokens(uint newAmount) onlyOwner public virtual returns(bool success)
 	{
 		availableTokens = newAmount;
 		return true;
 	}

 	function setNewTokenContract(address newTokenAddress) onlyOwner public virtual returns(bool success)
 	{
 		tokenContract = newTokenAddress;
 		token = Token(newTokenAddress);
 		return true;
 	}

 	function setNewRouterContract(address newRouterAddress) onlyOwner public virtual returns(bool success)
 	{
 		routerContract = newRouterAddress;
 		router = Router(newRouterAddress);
 		return true;
 	}

 	function flipSwitch() external onlyOwner returns(bool success)
 	{
 		active = !active;
 		return true;
 	}

//-----------PRIVATE--------------------   
 	function showMyCurrentRewardTotal() private view returns(uint reward)
 	{

 		if (denominator[msg.sender] == 0)
 		{
 			return 0;
 		}
 		else if (!active)
 		{
 			return 0;
 		}

 		uint gapSize = getGapSize();
 		uint rewardSize = (numerator[msg.sender].mul(gapSize)).div(denominator[msg.sender]);

 		if (rewardSize < minimumReturn[msg.sender])
 		{
 			rewardSize = minimumReturn[msg.sender];
 		}
 		if (rewardSize > getGapSize())
 		{
 			rewardSize = getGapSize();
 		}

 		return rewardSize;
 	}

 	function burn(uint burnAmount) isActive private returns(bool success)
 	{
 		require(burnAmount <= token.currentSupply(),
 			"at: solo_miner.sol | contract: SoloMiner | function: burn | message: You cannot burn more tokens than the existing current supply");
 		require(burnAmount <= token.balanceOf(msg.sender),
 			"at: solo_miner.sol | contract: SoloMiner | function: burn | message: You are trying to burn more than you own");

 		address toAddress = address(0);
 		address[2] memory addresseArr =[msg.sender, toAddress];
 		uint[2] memory uintArr =[burnAmount, 0];
 		router.extrenalRouterCall("burn", addresseArr, uintArr);
 		totalBurned = totalBurned.add(burnAmount);

 		return true;
 	}

 	function mint(uint mintAmount) isActive private returns(bool success)
 	{
 		address fromAddress = address(0);
 		address[2] memory addresseArr =[fromAddress, msg.sender];
 		uint[2] memory uintArr =[mintAmount, 0];
 		router.extrenalRouterCall("mint", addresseArr, uintArr);

 		return true;
 	}
 }
