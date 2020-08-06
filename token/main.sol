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

}


library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
 
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}






interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}






// WORK IN PROGRESS !!!!

abstract contract Routed is IERC20, Context {
    
using SafeMath for uint256;

mapping (address => uint256) private _balances; //TODO, is a call to ERC20
mapping (address => mapping (address => uint256)) private _allowances; //TODO, is a call to ERC20
    
function routed2(uint route, address[2] memory addressArr, uint[2] memory uintArr, bool[2] memory boolArr, bytes memory bytesVar, bytes32 bytes32Var, string memory stringVar) 
public returns (bool success){
    if(route == 0){
        _transfer(addressArr[0], addressArr[1], uintArr[0]);
    }
    else if(route == 1){
        _approve(addressArr[0], addressArr[1], uintArr[0]);
    }
    return true;
}
    
    
function routed3(uint route, address[3] memory addressArr, uint[3] memory uintArr, bool[3] memory boolArr, bytes memory bytesVar, bytes32 bytes32Var, string memory stringVar) 
public returns (bool success){
    if(route == 0){ //transferFrom
        uint256 amount = _allowances[addressArr[1]][addressArr[0]].sub(uintArr[0], "ERC20: transfer amount exceeds allowance");
        _transfer(addressArr[1], addressArr[2], uintArr[0]);
        _approve(addressArr[1], addressArr[0], amount); //todo check order of operations approve before transfer.
    }
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
    
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}







contract ERC20 is Routed {
    
    //-------------NOT ROUTED-----------------
    
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;


    constructor (string memory name, string memory symbol) {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }


    function name() public view returns (string memory) {
        return _name;
    }


    function symbol() public view returns (string memory) {
        return _symbol;
    }


    function decimals() public view returns (uint8) {
        return _decimals;
    }


    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    // function _setupDecimals(uint8 decimals_) internal {
    //     _decimals = decimals_;
    // }
//-----------------------------------------------------------------


//-------------------ROUTED----------------------------------------


    function transfer(address recipient, uint256 amount) public virtual override returns (bool success) {
        
        address[2] memory addresseArr = [_msgSender(), recipient];
        uint[2] memory uintArr = [amount,0];
        bool[2] memory boolArr;
        
        routed2(0,addresseArr, uintArr,boolArr,"","","");
        
        return true;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool success) {
        
        address[2] memory addresseArr = [_msgSender(), spender];
        uint[2] memory uintArr = [amount,0];
        bool[2] memory boolArr;
        
        routed2(1,addresseArr, uintArr,boolArr,"","","");
        
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        
        address[3] memory addresseArr = [_msgSender(), sender, recipient];
        uint[3] memory uintArr = [amount,0,0];
        bool[3] memory boolArr;
        
        routed3(0,addresseArr, uintArr,boolArr,"","","");
        
        return true;
 
    }

//--------------- TODO BELOW:

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }


    // function _transfer(address sender, address recipient, uint256 amount) internal virtual {
    //     require(sender != address(0), "ERC20: transfer from the zero address");
    //     require(recipient != address(0), "ERC20: transfer to the zero address");

    //     _beforeTokenTransfer(sender, recipient, amount);

    //     _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
    //     _balances[recipient] = _balances[recipient].add(amount);
    //     emit Transfer(sender, recipient, amount);
    // }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }


    // function _approve(address owner, address spender, uint256 amount) internal virtual {
    //     require(owner != address(0), "ERC20: approve from the zero address");
    //     require(spender != address(0), "ERC20: approve to the zero address");

    //     _allowances[owner][spender] = amount;
    //     emit Approval(owner, spender, amount);
    // }


    // function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
