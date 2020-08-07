// SPDX-License-Identifier: MIT

pragma solidity >= 0.5 .0 < 0.8 .0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context{
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
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


abstract contract Router {
    
function routed2(uint route, address[2] memory addressArr, uint[2] memory uintArr, bool[2] memory boolArr, bytes memory bytesVar, bytes32 bytes32Var, string memory stringVar) external virtual returns (bool success);
function routed3(uint route, address[3] memory addressArr, uint[3] memory uintArr, bool[3] memory boolArr, bytes memory bytesVar, bytes32 bytes32Var, string memory stringVar) external virtual returns (bool success);
    
}


contract ERC20 is Ownable{
    
    uint public currentRouterId;

    mapping (uint => address) private routerContract;
    Router private router;
    
    mapping (address=>bool) private isAllowedContract; //todo, for mint for example.
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply; //todo, is current supply

    string private _name = "Krakin't";
    string private _symbol = "KRAEK";
    uint8 private _decimals = 18;


    constructor () {
        routerContract[0] = address(0);
        currentRouterId = 0;
        router = Router(routerContract[currentRouterId]);
    }


    function totalSupply() public view returns (uint256 data) {
        return _totalSupply;
    }


    function balanceOf(address account) public view returns (uint256 data) {
        return _balances[account];
    }
    
    
    function allowance(address owner, address spender) public view virtual returns (uint256 data) {
        return _allowances[owner][spender];
    }
    
    function currentRouter() public view returns (address routerAddress) {
        return routerContract[currentRouterId];
    }
    
    function pastRouter(uint routerId) public view returns (address routerAddress){
        require(routerId<=currentRouterId);
        return routerContract[routerId];
    }
    
//-------------------------------------------------------------------------

function setNewRouterContract(address routerAddress) onlyOwner public virtual returns (bool success) {
    isAllowedContract[currentRouter()] = false; // we do not want old versions to be relevant anymore
    currentRouterId ++;
    routerContract[currentRouterId] = routerAddress;
    router = Router(routerContract[currentRouterId]);
    isAllowedContract[currentRouter()] = true; // we want the new version to be relevant, turn off manually if not relevant
    return true;
}

function setIsAllowedContract(address allowedContract, bool value) onlyOwner public virtual returns (bool success){
     isAllowedContract[allowedContract] = value;
     return true;
}
//-------------------START ROUTED----------------------------------------

    function transfer(address recipient, uint256 amount) public virtual returns (bool success) {
        
        address[2] memory addresseArr = [_msgSender(), recipient];
        uint[2] memory uintArr = [amount,0];
        bool[2] memory boolArr;
        
        router.routed2(0,addresseArr, uintArr,boolArr,"","","");
        
        return true;
    }

    function approve(address spender, uint256 amount) public virtual returns (bool success) {
        
        address[2] memory addresseArr = [_msgSender(), spender];
        uint[2] memory uintArr = [amount,0];
        bool[2] memory boolArr;
        
        router.routed2(1,addresseArr, uintArr,boolArr,"","","");
        
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool success) {
        address[3] memory addresseArr = [_msgSender(), sender, recipient];
        uint[3] memory uintArr = [amount,0,0];
        bool[3] memory boolArr;
        
        router.routed3(0,addresseArr, uintArr,boolArr,"","","");
        
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool success) {
        address[2] memory addresseArr = [_msgSender(), spender];
        uint[2] memory uintArr = [addedValue,0];
        bool[2] memory boolArr;
        
        router.routed2(2,addresseArr, uintArr,boolArr,"","","");
        
        return true;
    }
    
    
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool success) {
        address[2] memory addresseArr = [_msgSender(), spender];
        uint[2] memory uintArr = [subtractedValue,0];
        bool[2] memory boolArr;
        
        router.routed2(3,addresseArr, uintArr,boolArr,"","","");
        
        return true;
    }
    
    
    function burn(address account, uint256 amount) internal virtual returns (bool success) { //TODO: check the call type! internal/owner
        address[2] memory addresseArr = [account,address(0)];
        uint[2] memory uintArr = [amount,0];
        bool[2] memory boolArr;
        
        router.routed2(4,addresseArr, uintArr,boolArr,"","","");
        
        return true;
    }

    
    function mint(address account, uint256 amount) internal virtual returns (bool success) { //TODO: check the call type! internal/owner
        address[2] memory addresseArr = [account,address(0)];
        uint[2] memory uintArr = [amount,0];
        bool[2] memory boolArr;
        
        router.routed2(5,addresseArr, uintArr,boolArr,"","","");
        
        return true;   
    }
    
//-------------------END ROUTED----------------------------------------

}
