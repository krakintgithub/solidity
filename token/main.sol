//TODO: Remove this file once everything is done


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

    function transfer(address recipient, uint256 amount) external returns (bool success);
    function approve(address spender, uint256 amount) external returns (bool success);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool success);

    function totalSupply() external view returns (uint256 data);
    function balanceOf(address account) external view returns (uint256 data);
    function allowance(address owner, address spender) external view returns (uint256 data);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}






// WORK IN PROGRESS !!!!


abstract contract Core is IERC20, Context{
    using SafeMath for uint256;

mapping (address => uint256) private _balances; //TODO, is a call to ERC20
mapping (address => mapping (address => uint256)) private _allowances; //TODO, is a call to ERC20
uint256 private _totalSupply; //TODO, is a call to ERC20
    
    function _transfer(address[2] memory addressArr, uint[2] memory uintArr) internal virtual returns (bool success) {
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
    
    
    function _transferFrom(address[3] memory addressArr, uint[3] memory uintArr) internal virtual returns (bool success) {
        uint256 amount = _allowances[addressArr[1]][addressArr[0]].sub(uintArr[0], "ERC20: transfer amount exceeds allowance");
        address[2] memory tmpAddresses1 = [addressArr[1], addressArr[2]];
        address[2] memory tmpAddresses2 = [addressArr[1], addressArr[0]];
        
        uint[2] memory tmpUint = [uintArr[0],uintArr[1]];

        _transfer(tmpAddresses1, tmpUint);
        _approve(tmpAddresses2, tmpUint); //todo check order of operations, approve before transfer.
        return true;
    }
    
    
    function _approve(address[2] memory addressArr, uint[2] memory uintArr) internal virtual {
        address owner = addressArr[0];
        address spender = addressArr[1];
        uint amount = uintArr[0];
        
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
 
    function increaseAllowance(address[2] memory addressArr, uint[2] memory uintArr) public virtual returns (bool success) {
        uintArr[0] = _allowances[addressArr[0]][addressArr[1]].add(uintArr[0]);
        _approve(addressArr, uintArr);
        return true;
    }
    
    function decreaseAllowance(address[2] memory addressArr, uint[2] memory uintArr) public virtual returns (bool success) {
        uintArr[0] = _allowances[addressArr[0]][addressArr[1]].sub(uintArr[0], "ERC20: decreased allowance below zero");
        _approve(addressArr, uintArr);
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


abstract contract Routed is Core {
    

function routed2(uint route, address[2] memory addressArr, uint[2] memory uintArr, bool[2] memory boolArr, bytes memory bytesVar, bytes32 bytes32Var, string memory stringVar) 
public returns (bool success){
    if(route == 0){
        _transfer(addressArr, uintArr);
    }
    else if(route == 1){
        _approve(addressArr, uintArr);
    }
    else if(route == 2){
        increaseAllowance(addressArr, uintArr);
    }
    else if(route==3){
        decreaseAllowance(addressArr, uintArr);
    }
    else if(route==4){ //burn
        burn(addressArr, uintArr);
    }
    else if(route==5){ //mint
        mint(addressArr, uintArr);        
    }
    return true;
}
    
    
function routed3(uint route, address[3] memory addressArr, uint[3] memory uintArr, bool[3] memory boolArr, bytes memory bytesVar, bytes32 bytes32Var, string memory stringVar) 
public returns (bool success){
    if(route == 0){ //transferFrom
        _transferFrom(addressArr, uintArr);
    }
    return true;
}  
    

}


contract ERC20 is Routed {
    
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply; //todo, is current supply

    string private _name = "Krakin't";
    string private _symbol = "KRAEK";
    uint8 private _decimals = 18;


    constructor () {
    }


    function totalSupply() public view override returns (uint256 data) {
        return _totalSupply;
    }


    function balanceOf(address account) public view override returns (uint256 data) {
        return _balances[account];
    }
    
    
    function allowance(address owner, address spender) public view virtual override returns (uint256 data) {
        return _allowances[owner][spender];
    }
    
//-------------------START ROUTED----------------------------------------

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool success) {
        address[3] memory addresseArr = [_msgSender(), sender, recipient];
        uint[3] memory uintArr = [amount,0,0];
        bool[3] memory boolArr;
        
        routed3(0,addresseArr, uintArr,boolArr,"","","");
        
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool success) {
        address[2] memory addresseArr = [_msgSender(), spender];
        uint[2] memory uintArr = [addedValue,0];
        bool[2] memory boolArr;
        
        routed2(2,addresseArr, uintArr,boolArr,"","","");
        
        return true;
    }
    
    
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool success) {
        address[2] memory addresseArr = [_msgSender(), spender];
        uint[2] memory uintArr = [subtractedValue,0];
        bool[2] memory boolArr;
        
        routed2(3,addresseArr, uintArr,boolArr,"","","");
        
        return true;
    }
    
    
    function burn(address account, uint256 amount) internal virtual returns (bool success) { //TODO: check the call type! internal/owner
        address[2] memory addresseArr = [account,address(0)];
        uint[2] memory uintArr = [amount,0];
        bool[2] memory boolArr;
        
        routed2(4,addresseArr, uintArr,boolArr,"","","");
        
        return true;
    }

    
    function mint(address account, uint256 amount) internal virtual returns (bool success) { //TODO: check the call type! internal/owne
        address[2] memory addresseArr = [account,address(0)];
        uint[2] memory uintArr = [amount,0];
        bool[2] memory boolArr;
        
        routed2(5,addresseArr, uintArr,boolArr,"","","");
        
        return true;   
    }
    
//-------------------END ROUTED----------------------------------------


}
