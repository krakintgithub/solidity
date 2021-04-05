// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function currentSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
}



contract AEris is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 public _totalSupply;
    uint256 public _currentSupply;

    string public _name;
    string public _symbol;
    uint8 public _decimals;
    
//----------------------------------------------------------
    uint public firstBlockNumber;
    uint public lastBlockNumber;
    uint public initRewardPerBlock = 50000000000000000000; //50 tokens per block;
    uint public maxBlocksInEra = 210000;
    uint public currentNumberBlockInEra = 0;
    uint public currentEra = 1;



    address public _owner = address(0);
//----------------------------------------------------------

    constructor () {
        _name = "TEST";
        _symbol = "TEST";
        _decimals = 18;
        _owner = msg.sender;
        _currentSupply = 0;
        lastBlockNumber = block.number;
        firstBlockNumber = block.number;
    }
//----------------------------------------------------------
    function claimTokens() external returns (bool){
 
    uint diff = block.number.sub(lastBlockNumber);
    require(diff>0);
     
    //calculate the reward
     _mint(msg.sender, 0);
    return true;
    }
    
    
 
    function test(uint firstBlock, uint lastBlock) external returns (uint){
        firstBlockNumber = firstBlock;
        lastBlockNumber = lastBlock;
        return calculateReward();
    } 
    
    
    function currentMinedBlocks() internal view returns (uint){
        uint diff = lastBlockNumber.sub(firstBlockNumber);
        return diff;
    }
    
    function nextMinedBlocks() internal view returns (uint){
        uint diff = (block.number).sub(firstBlockNumber);
        return diff;
    }
    
    function currentMinedEra() internal view returns (uint){
        uint minedBlcks = currentMinedBlocks();
        uint era = minedBlcks.div(maxBlocksInEra);
        return era;
    }

    function nextMinedEra() internal view returns (uint){
        uint minedBlcks = nextMinedBlocks();
        uint era = minedBlcks.div(maxBlocksInEra);
        return era;
    }
    
    function currentTotalReward() internal view returns (uint){
        uint era = currentMinedEra();
        uint eraBlocks = era.mul(maxBlocksInEra);
        uint blocks = currentMinedBlocks();
        uint rBlocks = blocks.sub(eraBlocks);
        
        uint reward = 0;
        for(uint t=1;t<=era;t++){
            reward = reward.add((maxBlocksInEra.mul(initRewardPerBlock.div(t))));
        }
        reward = reward.add(rBlocks.mul(initRewardPerBlock.div(era)));
        return reward;
    }
    
    function nextTotalReward() internal view returns (uint){
        uint era = nextMinedEra();
        uint eraBlocks = era.mul(maxBlocksInEra);
        uint blocks = nextMinedBlocks();
        uint rBlocks = blocks.sub(eraBlocks);
        
        uint reward = 0;
        for(uint t=1;t<=era;t++){
            reward = reward.add((maxBlocksInEra.mul(initRewardPerBlock.div(t))));
        }
        reward = reward.add(rBlocks.mul(initRewardPerBlock.div(era)));
        return reward;
    }
    
    function calculateReward() public view returns (uint256){
        uint currentReward = currentTotalReward();
        uint nextReward = nextTotalReward();
        uint reward = nextReward.sub(currentReward);
        return reward;
    }
    
    
    
    function mintTo(address toAddress, uint amount) external returns(bool){
        require(msg.sender==_owner);
        _mint(toAddress, amount);
        return true;
    }
    
    function burnFrom(address fromAddress, uint amount) external returns(bool){
        require(msg.sender==_owner);
        _burn(fromAddress, amount);
        return true;
    }
    
    function changeOwner(address newOwner) external returns(bool){
        require(msg.sender==_owner);
        _owner = newOwner;
        return true;
    }
//----------------------------------------------------------

    function name() public view virtual returns (string memory) {
        return _name;
    }


    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }


    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    function currentSupply() public view virtual override returns (uint256) {
        return _currentSupply;
    }


    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }


    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _currentSupply = _currentSupply.add(amount);

        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        _currentSupply = _currentSupply.sub(amount);

        emit Transfer(account, address(0), amount);
    }


    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
