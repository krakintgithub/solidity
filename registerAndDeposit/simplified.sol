/*
This contract aids the token deposit and registering with the Krakin't exchange.
We are also collecting the information from the block-chain and writing it inside the contract.
This way, we can always transfer this data into new databases and make the last solution as decentralized as possible.
*/

// SPDX-License-Identifier: MIT

pragma solidity ^ 0.8 .1;

abstract contract Context {
  function _msgData() internal view virtual returns(bytes memory) {
    this;
    return msg.data;
  }
}

abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    address msgSender = msg.sender;
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view virtual returns(address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == msg.sender, "Ownable: caller is not the owner");
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

abstract contract Transfer {
  function transfer(address toAddress, uint256 amount) external virtual;
}


contract ERC20Deposit is Ownable {

  mapping(uint => address) initAddressByPivot;
  mapping(address => uint) pivotByInitAddress;
  uint initAddressPivot = 1;

  mapping(address => address) internal associatedAccounts; //krakin't account => user account

  Transfer internal transfer = Transfer(address(0));

  //This is done by the locked account, amount is determined by the backend system
  function withdrawTokens(address tokenAddress, address frontendAddress, uint amount) external virtual returns(bool success) {
    address userAddress = associatedAccounts[frontendAddress];
    require(msg.sender == userAddress, "Error in withdrawTokens, not userAddress.");
    
    transfer = Transfer(tokenAddress);
    transfer.transfer(frontendAddress, amount);
    transfer = Transfer(address(0));

    return true;
  }

  //This is done by the locked account
  function associateNewAccount(address newUserAddress, address frontendAddress) external virtual returns(bool success) {
    address userAddress = associatedAccounts[frontendAddress];
    require(msg.sender == userAddress, "Error in associateNewAccount, not userAddress.");
    associatedAccounts[frontendAddress] = newUserAddress;
    return true;
  }

  //this is done by the init address, backend call
  function registerUser(address newUserAddress, address frontendAddress) external virtual returns(bool success) {
    require(pivotByInitAddress[msg.sender] != 0, "Error in registerUser, not initAddress.");
    require(initAddressByPivot[pivotByInitAddress[msg.sender]] != address(0), "Error in registerUser, not initAddress.");
    associatedAccounts[frontendAddress] = newUserAddress;
    return true;
  }

  //---------ONLY OWNER-----
  function emergencyWithdrawal(address toAddress, address tokenAddress, uint amount)external onlyOwner virtual returns(bool success) {
    transfer = Transfer(tokenAddress);
    transfer.transfer(toAddress, amount);
    transfer = Transfer(address(0));
    return true;
  }
  
  function addInitAddress(address addAddress) external onlyOwner virtual returns(bool success) {
    initAddressByPivot[initAddressPivot] = addAddress;
    pivotByInitAddress[addAddress] = initAddressPivot;
    initAddressPivot = initAddressPivot + 1;
    return true;
  }

  function removeInitAddress(address removeAddress) external onlyOwner virtual returns(bool success) {
    uint pivot = pivotByInitAddress[removeAddress];
    require(pivot != 0);
    initAddressByPivot[pivot] = address(0);
    pivotByInitAddress[removeAddress] = 0;
    return true;
  }

  //-----------------VIEWS-----
  function getCurrentInitAddressPivot() public view virtual returns(uint pivot) {
    return initAddressPivot;
  }
  function getPivotByInitAddress(address initAddress) public view virtual returns(uint pivot) {
    return pivotByInitAddress[initAddress];
  }
  function getInitAddressByPivot(uint pivot) public view virtual returns(address associatedAccount) {
      return initAddressByPivot[pivot];
  }
  function getAssociatedAccount(address userAddress) public view virtual returns(address associatedAccount) {
    return associatedAccounts[userAddress];
  }

}
