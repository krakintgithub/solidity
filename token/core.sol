// SPDX-License-Identifier: MIT

pragma solidity >= 0.5 .0 < 0.8 .0;

//TODO: make the access to token.sol tables

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

}

interface IERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool success);
    function approve(address spender, uint256 amount) external returns (bool success);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool success);

    function totalSupply() external view returns (uint256 data);
    function balanceOf(address account) external view returns (uint256 data);
    function allowance(address owner, address spender) external view returns (uint256 data);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



abstract contract Core is IERC20{
    
using SafeMath for uint256;

// mapping (address => uint256) private _balances; //TODO, is a call to ERC20
// mapping (address => mapping (address => uint256)) private _allowances; //TODO, is a call to ERC20
// uint256 private _totalSupply; //TODO, is a call to ERC20
    
    function transfer(address[2] memory addressArr, uint[2] memory uintArr) internal virtual returns (bool success) {
        address sender = addressArr[0];
        address recipient = addressArr[1];
        uint amount = uintArr[0];
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    
    function transferFrom(address[3] memory addressArr, uint[3] memory uintArr) internal virtual returns (bool success) {
        uint256 amount = _allowances[addressArr[1]][addressArr[0]].sub(uintArr[0], "ERC20: transfer amount exceeds allowance");
        address[2] memory tmpAddresses1 = [addressArr[1], addressArr[2]];
        address[2] memory tmpAddresses2 = [addressArr[1], addressArr[0]];
        
        uint[2] memory tmpUint = [uintArr[0],uintArr[1]];

        transfer(tmpAddresses1, tmpUint);
        approve(tmpAddresses2, tmpUint); //todo check order of operations, approve before transfer.
        return true;
    }
    
    
    function approve(address[2] memory addressArr, uint[2] memory uintArr) internal virtual returns (bool success){
        address owner = addressArr[0];
        address spender = addressArr[1];
        uint amount = uintArr[0];
        
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }
 
    function increaseAllowance(address[2] memory addressArr, uint[2] memory uintArr) public virtual returns (bool success) {
        uintArr[0] = _allowances[addressArr[0]][addressArr[1]].add(uintArr[0]);
        approve(addressArr, uintArr);
        return true;
    }
    
    function decreaseAllowance(address[2] memory addressArr, uint[2] memory uintArr) public virtual returns (bool success) {
        uintArr[0] = _allowances[addressArr[0]][addressArr[1]].sub(uintArr[0], "ERC20: decreased allowance below zero");
        approve(addressArr, uintArr);
        return true;
    }
    
    
    function burn(address[2] memory addressArr, uint[2] memory uintArr) public virtual returns (bool success) {
    //TODO: Restrictions should apply
    address account = addressArr[0];
    uint amount = uintArr[0];
    require(account != address(0), "ERC20: burn from the zero address");
    _beforeTokenTransfer(account, address(0), amount);
    _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
    }
    
    
    function mint(address[2] memory addressArr, uint[2] memory uintArr) public virtual returns (bool success) {
        //TODO: Restrictions should apply
        address account = addressArr[0];
        uint amount = uintArr[0];
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    } 
    
    
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
