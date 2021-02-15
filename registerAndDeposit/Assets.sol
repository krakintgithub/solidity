/*
This contract aids the token deposit and registering with the Krakin't exchange.
Data already exists on a block-chain and therefore, it has to be accessed via API calls.
The Administrator account is used to send tokens to and out of the exchange.
Since the Administrator account needs GAS, the users need to deposit the Ethereum necessary to run this contract.
We are also collecting the information from the block-chain and writing it inside the contract.
This way, we can always transfer this data into new databases and make the last solution as decentralized as possible.
There are 3 primary accounts associated with this contract:
- The owner account
- The external contract contract
- The oracle contract

The purpose of the owner is the general maintenance of the contract.
The purpose of admin is to connect to an outside wallet to do the main contract interaction.
The purpose of the external contract is to act as an admin, and as a decentralized solution while standing in a middle.
The purpose of the oracle contract is to enable communication with the oracles to call the blockchain API rather than having a centralized solution.
*/

// SPDX-License-Identifier: MIT

pragma solidity ^ 0.7 .4;

abstract contract Context {
  function _msgSender() internal view virtual returns(address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns(bytes memory) {
    this;
    return msg.data;
  }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

}

contract ERC20Deposit is Ownable {
  using SafeMath
  for uint;
  
  address initAddress = address(0);

  mapping(address => uint) internal registration; //for account flagging, 100 is blacklisted
  mapping(address => string) internal registerData; //for registering tokens, projects, etc
  mapping(address => address) internal associatedAccounts; //krakin't account => user account

  //---------------------------------
  uint internal transactionPivot;
  mapping(uint => string) internal registeredTransactions;
  //------------------

  Transfer internal transfer = Transfer(address(0));

  //we don't need to register ETH deposits, it is done by the frontend
  //recover ETH from Admin is a web3 function, not a contract, then another call to registerNewEthBalance is made

  //==== TOKEN ====
  //this is done by the frontend,  we can always read txHash
  function registerNewTokenBalance(string memory txHash) external virtual returns(bool success) {
    transactionPivot = transactionPivot.add(1);
    registeredTransactions[transactionPivot] = txHash;
    return true;
  }

    //This is done by the locked account, amount is determined by the backend system
  function withdrawTokens(address tokenAddress, address frontendAddress, uint amount, string memory message) external virtual returns(bool success) {
    
    address userAddress = associatedAccounts[frontendAddress];
    require(msg.sender == userAddress);
    require(registration[tokenAddress]!=100);

    transfer = Transfer(tokenAddress);

    transfer.transfer(frontendAddress, amount);
    transfer = Transfer(0);
    
    transactionPivot = transactionPivot.add(1);
    registeredTransactions[transactionPivot] = message;

    return true;
  }
  
  //This is done by the locked account
  function associateNewAccount(address newUserAddress, address frontendAddress) external virtual returns(bool success) {
      address userAddress = associatedAccounts[frontendAddress];
      require(msg.sender == userAddress);
      associatedAccounts[frontendAddress] = newUserAddress;
      return true;
  }
  
  //this is done by the init address
  function registerUser(address newUserAddress, address frontendAddress) external virtual returns(bool success){
      require(msg.sender == initAddress);
      associatedAccounts[frontendAddress] = newUserAddress;
      return true;
  }
  

  //---------helpers-------

  
  
function uint2str( uint256 _i) internal pure returns(string memory str) {
    if (_i == 0) { return "0"; }
    uint256 j = _i;
    uint256 length;
    while (j != 0) { length++; j /= 10; }
    bytes memory bstr = new bytes(length);
    uint256 k = length;
    j = _i;
    while (j != 0) { bstr[--k] = bytes1(uint8(48 + j % 10)); j /= 10; }
    str = string(bstr);
}
  

}

contract OnlyOwner is ERC20Deposit {

  function setInitAddress(address newAddress) external onlyOwner virtual returns(bool success) {
    initAddress = newAddress;
    return true;
  }
  

  function setAccountFlag(address regAddress, uint flagType) external onlyOwner virtual returns(bool success) {
    registration[regAddress] = flagType;
    return true;
  }

  function updateRegisterData(address userAddress, string memory data) external virtual onlyOwner returns(bool success) {
    registerData[userAddress] = data;
    return true;
  }


}

contract Views is ERC20Deposit {

  function getExternalContractAddress() public view virtual returns(address externalContract) {
    return externalContract;
  }

  function getAccountFlag(address userAddress) public view virtual returns(uint accountFlag) {
    return registration[userAddress];
  }

  function getRegisterData(address userAddress) public view virtual returns(string memory data) {
    return registerData[userAddress];
  }

  function getPivot() public view virtual returns(uint pivot) {
    return pivot;
  }

  function getTransactionPivot() public view virtual returns(uint pivot) {
    return transactionPivot;
  }

  function getTransactionFromPivot(uint pivot) public view virtual returns(string memory txHash) {
    return registeredTransactions[pivot];
  }

}
