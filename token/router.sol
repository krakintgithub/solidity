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




abstract contract Core {
    
function transfer(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns (bool success);
function approve(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns (bool success);
function increaseAllowance(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns (bool success);
function decreaseAllowance(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns (bool success);
function burn(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns (bool success);
function mint(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns (bool success);
function transferFrom(address[3] memory addressArr, uint[3] memory uintArr) external virtual returns (bool success);

}

contract Router is Ownable {

uint public currentCoreId;
mapping (uint => address) private coreContract;
Core private core;

mapping (address=>bool) private isAllowedContract; //todo, for mint for example.


constructor () {
    coreContract[0] = address(0);
    currentCoreId = 0;
    core = Core(coreContract[currentCoreId]);
}


function equals (string memory a, string memory b) public view returns (bool isEqual) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
}


function currentCore() public view returns (address routerAddress) {
    return coreContract[currentCoreId];
}
    
function getIsAllowedContract(address contractAddress) public view virtual returns (bool isAllowed){
    return isAllowedContract[contractAddress];
}
    
function setNewCoreContract(address coreAddress) onlyOwner public virtual returns (bool success) {
    isAllowedContract[currentCore()] = false; // we do not want old versions to be relevant anymore
    currentCoreId ++;
    coreContract[currentCoreId] = coreAddress;
    core = Core(coreContract[currentCoreId]);
    isAllowedContract[currentCore()] = true; // we want the new version to be relevant, turn off manually if not relevant
    return true;
}

function setIsAllowedContract(address allowedContract, bool value) onlyOwner public virtual returns (bool success){
     isAllowedContract[allowedContract] = value;
     return true;
}


function routed2(string memory route, address[2] memory addressArr, uint[2] memory uintArr, bool[2] memory boolArr, bytes memory bytesVar, bytes32 bytes32Var, string memory stringVar) 
public returns (bool success){
    if(equals(route, "transfer")){
        core.transfer(addressArr, uintArr);
    }
    else if(equals(route, "approve")){
        core.approve(addressArr, uintArr);
    }
    else if(equals(route, "increaseAllowance")){
        core.increaseAllowance(addressArr, uintArr);
    }
    else if(equals(route, "decreaseAllowance")){
        core.decreaseAllowance(addressArr, uintArr);
    }
    else if(equals(route, "burn")){
        core.burn(addressArr, uintArr);
    }
    else if(equals(route, "mint")){
        core.mint(addressArr, uintArr);        
    }
    return true;
}
    
    
    function routed3(string memory route, address[3] memory addressArr, uint[3] memory uintArr, bool[3] memory boolArr, bytes memory bytesVar, bytes32 bytes32Var, string memory stringVar) 
    public returns (bool success){
        if(equals(route, "transferFrom")){
            core.transferFrom(addressArr, uintArr);
        }
        return true;
    }  
    

}
