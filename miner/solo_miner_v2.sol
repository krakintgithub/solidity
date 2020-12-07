/*



*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7 .0;

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
    // assert(a == b *c + a % b);	// There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns(uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
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


abstract contract OldVersionMiner {
    function getPivot() external view virtual returns(uint lastPivot);
    function getAddressFromId(uint id) external view virtual returns(address minerAddress);
    function showReward(address minerAddress) public view virtual returns(uint reward);
}

abstract contract Token {

  function balanceOf(address account) external view virtual returns(uint256 data);

}

abstract contract Router {

  function extrenalRouterCall(string memory route, address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);

  function updateCurrentSupply(uint[2] memory uintArr) external virtual returns(bool success);
}

//===============================================================
//MAIN CONTRACT
//===============================================================
contract SoloMiner is Ownable {
  using SafeMath
  for uint;

  address public tokenContract;
  address public routerContract;


  Token private token;
  Router private router;
  OldVersionMiner private oldVersionMiner;
  
  mapping(address => uint) private userBlocks;
  mapping(address => uint) private miners;
  mapping(uint => address) private addressFromId;
  mapping(address => uint) private depositedTokens;


  uint public pivot = 0;
  uint private rewardConstant = 100000000000000000000;
  uint public totalConstant = 21000000000000000000000000; //we assume that there is a 21 million as a total supply
  uint public countdownConstant = 69444444444444; //starts with 1% earning per day, decreases to 190258751902 in 20 years, 1317612 per block
  uint public decreaseConstant = 1317612;
  uint public withdrawNum = 0;
  uint public depositNum = 0;
  uint public startBlock = 0;

  address private contractAddress;
  
  
  
  uint public totalBurned = 0;
  uint public totalMinted = 0;

  constructor() {
    contractAddress = address(this);
    oldVersionMiner = OldVersionMiner(address(0x8658299fD312BfFD5F1aF515A031BE93ACe3BF88)); //TODO, CHANGE THIS BEFORE DEPLOY!
    uint oldPivot = oldVersionMiner.getPivot();
    
    uint currentBlockNumber = getCurrentBlockNumber();
    startBlock = currentBlockNumber;
    for(uint i=1;i<=oldPivot;i++){
        address oldAddress = oldVersionMiner.getAddressFromId(i);
        uint tokens = oldVersionMiner.showReward(oldAddress);
        

        
        miners[oldAddress] = i;
        addressFromId[i] = oldAddress;
        depositedTokens[oldAddress] = tokens;
        userBlocks[oldAddress] = currentBlockNumber;
    }
    pivot = oldPivot;
  }



  //+++++++++++VIEWS++++++++++++++++
  //----------GETTERS---------------
  
  
  
  function getPivot() external view virtual returns(uint lastPivot) {
    return pivot;
  }

  function getAddressFromId(uint id) external view virtual returns(address minerAddress) {
    return addressFromId[id];
  }

  function getUserBlocks(address minerAddress) external view virtual returns(uint minerBlocks) {
    return userBlocks[minerAddress];
  }

  function getContractAddress() external view virtual returns(address tokenAddress) {
    return contractAddress;
  }

  function getTokenContract() external view virtual returns(address tokenAddress) {
    return tokenContract;
  }

  function getTotalBurned() external view virtual returns(uint burned) {
    return totalBurned;
  }

  function getTotalMinted() external view virtual returns(uint burned) {
    return totalMinted;
  }

  function getLastBlockNumber(address minerAddress) public view virtual returns(uint lastBlock) {
    return userBlocks[minerAddress];
  }

  function getRouterContract() external view virtual returns(address routerAddress) {
    return routerContract;
  }

  function getCurrentBlockNumber() public view returns(uint256 blockNumber) {
    return block.number;
  }
 
  function getRewardConstant() external view virtual returns(uint routerAddress) {
    return rewardConstant;
  }

  function getTotalConstant() external view virtual returns(uint routerAddress) {
    return totalConstant;
  }

  //----------OTHER VIEWS---------------

  function showEarned(address minerAddress) public view virtual returns(uint reward) {
    uint previousBlock = getLastBlockNumber(minerAddress);
    uint currentBlock = getCurrentBlockNumber();
    uint diff = currentBlock.sub(previousBlock);
    uint deposited = depositedTokens[minerAddress];
    
    if(rewardConstant==0){return 0;}
    uint constantCntDwn = countdownConstant.sub(withdrawNum);
    uint earned = ((deposited.mul(diff)).mul(constantCntDwn)).div(rewardConstant);
    return earned;
    
  }

  function showReward(address minerAddress) public view virtual returns(uint reward) {
      uint earned = showEarned(minerAddress);
      uint ret = depositedTokens[minerAddress].add(earned);
      return ret;
  }

  //+++++++++++EXTERNAL++++++++++++++++
  function mine(uint depositAmount) external virtual returns(bool success) {
    require(depositAmount > 0, "solo_miner:mine:No zero deposits");
    registerMiner();

    uint reward = showReward(msg.sender);
    uint deposit = reward.add(depositAmount);

    burn(depositAmount);
    
    depositedTokens[msg.sender] = deposit;
    userBlocks[msg.sender] = getCurrentBlockNumber();
    depositNum = depositNum.add(1);
    
    return true;
  }

  function getReward(uint withdrawAmount) public virtual returns(bool success) {
    require(getLastBlockNumber(msg.sender) > 0, "solo_miner:getReward:Must mine first");

    uint reward = showReward(msg.sender);
    require(withdrawAmount <= reward, "solo_miner:getReward:Amount too big");
    registerMiner();
    
    uint balance = reward.sub(withdrawAmount);
    
    depositedTokens[msg.sender] = balance;
    userBlocks[msg.sender] = getCurrentBlockNumber();

    withdrawNum = withdrawNum.add(1);

    mint(withdrawAmount);

    return true;
  }

  function getFullReward() public virtual returns(bool success) {
    uint amt = showReward(msg.sender);
    getReward(amt);
    return true;
  }

  //in case you want to burn tokens and increase miner rewards
  function burnMyTokens(uint tokenAmount) public virtual returns(bool success) {
    burn(tokenAmount);
    return true;
  }

  //+++++++++++ONLY OWNER++++++++++++++++
  //----------SETTERS--------------------
  function setNewTokenContract(address newTokenAddress) onlyOwner public virtual returns(bool success) {
    tokenContract = newTokenAddress;
    token = Token(newTokenAddress);
    return true;
  }
  
  function setNewRouterContract(address newRouterAddress) onlyOwner public virtual returns(bool success) {
    routerContract = newRouterAddress;
    router = Router(newRouterAddress);
    return true;
  }

  function setRewardConstant(uint newConstant) onlyOwner public virtual returns(bool success) {
    rewardConstant = newConstant;
    return true;
  }


  function setTotalConstant(uint newConstant) onlyOwner public virtual returns(bool success) {
    totalConstant = newConstant;
    return true;
  }

  //+++++++++++PRIVATE++++++++++++++++++++   
  function registerMiner() private {
    if (miners[msg.sender] == 0) {
      pivot = pivot.add(1);
      miners[msg.sender] = pivot;
      addressFromId[pivot] = msg.sender;
    }
  }

  function burn(uint burnAmount) private returns(bool success) {
    require(burnAmount <= token.balanceOf(msg.sender), "solo_miner:burn:You are trying to burn more than you own");

    address toAddress = address(0);
    address[2] memory addresseArr = [msg.sender, toAddress];
    uint[2] memory uintArr = [burnAmount, 0];

    totalBurned = totalBurned.add(burnAmount);
    
    router.extrenalRouterCall("burn", addresseArr, uintArr); //TODO "burn_miner"

    return true;
  }
  
  function mint(uint mintAmount) private returns(bool success) {
    address fromAddress = address(0);
    address[2] memory addresseArr = [fromAddress, msg.sender];
    uint[2] memory uintArr = [mintAmount, 0];

    totalMinted = totalMinted.add(mintAmount);

    router.extrenalRouterCall("mint", addresseArr, uintArr); //TODO "mint_miner"

    return true;
  }
}
