// SPDX-License-Identifier: MIT

pragma solidity = 0.7.0;

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

interface IERC20 {
  function currentCoreContract() external view returns(address routerAddress);

  function currentTokenContract() external view returns(address routerAddress);

  function getExternalContractAddress(string memory contractName) external view returns(address routerAddress);

  function routed2(string memory route, address[2] memory addressArr, uint[2] memory uintArr) external returns(bool success);
  
  function routed3(string memory route, address[3] memory addressArr, uint[3] memory uintArr) external returns(bool success);


}

abstract contract Core {

  function transfer(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);

  function approve(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);

  function increaseAllowance(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);

  function decreaseAllowance(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);

  function transferFrom(address[3] memory addressArr, uint[3] memory uintArr) external virtual returns(bool success);

}

//============================================================================================
// MAIN CONTRACT 
//============================================================================================
contract Router is Ownable, IERC20 {

  address public tokenContract;
  address public coreContract;
  Core private core;

  mapping(string => address) public otherContracts;

  bool private mainConstructorLocked = false;

  constructor() {
    if (!mainConstructorLocked) {
      tokenContract = address(0xE4F82Ed7FEcfae6629d034332A89F4830b74ed27); //Can be hardcoded or use address(0) and uncomment setNewCoreContract
      coreContract = address(0);
      mainConstructorLocked = true;
    }
  }

  //============== CORE FUNCTIONS START HERE ==================================================
  //These functions should never change when introducing a new version of a router.
  //Router is expected to constantly change, and the code should be written under 
  //the "NON-CORE FUNCTIONS TO BE CODED BELOW".

  function equals(string memory a, string memory b) internal view virtual returns(bool isEqual) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
  }

  function currentTokenContract() override external view virtual returns(address routerAddress) { //view
    return tokenContract;
  }

  function currentCoreContract() override external view virtual returns(address routerAddress) { //view
    return coreContract;
  }

  function getExternalContractAddress(string memory contractName) override external view virtual returns(address routerAddress) { //view
    return otherContracts[contractName];
  }

  function setNewTokenContract(address newTokenAddress) onlyOwner public virtual returns(bool success) { //owner
    tokenContract = newTokenAddress;
    return true;
  }

  //function is not needed if token address is hard-coded in a constructor
  //   function setNewCoreContract(address newCoreAddress) onlyOwner public virtual returns(bool success) { //owner
  //     coreContract = newCoreAddress;
  //     core = Core(coreContract);
  //     return true;
  //   }

  function setNewOtherContract(string memory contractName, address newContractAddress) onlyOwner public virtual returns(bool success) { //owner
    otherContracts[contractName] = newContractAddress;
    return true;
  }

  function routed2(string memory route, address[2] memory addressArr, uint[2] memory uintArr) override external virtual returns(bool success) { //from token
    require(msg.sender == tokenContract);

    if (equals(route, "transfer")) {
      core.transfer(addressArr, uintArr);
    } else if (equals(route, "approve")) {
      core.approve(addressArr, uintArr);
    } else if (equals(route, "increaseAllowance")) {
      core.increaseAllowance(addressArr, uintArr);
    } else if (equals(route, "decreaseAllowance")) {
      core.decreaseAllowance(addressArr, uintArr);
    }
    return true;
  }

  function routed3(string memory route, address[3] memory addressArr, uint[3] memory uintArr)  override external virtual returns(bool success) { //from token

    require(msg.sender == tokenContract);

    if (equals(route, "transferFrom")) {
      core.transferFrom(addressArr, uintArr);
    }
    return true;
  }
  //============== CORE FUNCTIONS END HERE ==================================================

  //=============== NON-CORE FUNCTIONS TO BE CODED BELOW ====================================

}
