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

contract Ownable is Context {
  address private _owner;
  bool private pause;

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

  modifier notPaused() {
    require(!pause, "Pause: contract is paused");
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

abstract contract Transfer1 {
  function transfer(address toAddress, uint256 amount) external virtual;
  function transferFrom(address sender, address recipient, uint256 amount) external virtual;
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

contract Assets is Ownable {
  using SafeMath
  for uint;

  mapping(address => uint) private depositedEth;
  mapping(address => uint) private adminEth;
  mapping(address => mapping(address => uint)) private depositedTokens; // userAddress=>tokencontract=>amount
  mapping(address => uint) private tokenBalance;
  mapping(address => uint) private registration; //for account flagging, 100 is blacklisted
  mapping(address => bool) private tokenBlacklist;
  mapping(uint => address) private registeredUserAddresses;
  mapping(address => string) private registerData; //for registering tokens, projects, etc

  uint private lastBlock;
  uint private pivot;

  bool private safety;
  bool private pause;

  address private adminAddress;
  address private ownerAddress;
  address private nextContractAddress;

  Transfer1 private transfer1;

  constructor() {
    adminAddress = msg.sender;
    ownerAddress = msg.sender;
    nextContractAddress = address(0);
    
    transfer1 = Transfer1(address(0));
  }

  //==== ETH ====

  function depositEth() external payable notPaused {
    require(msg.value > 0);
    require(lastBlock < block.number);
    require(msg.sender != adminAddress);
    require(registration[msg.sender] != 100);
    require(!safety);

    registerUser();

    depositedEth[msg.sender] = depositedEth[msg.sender].add(msg.value);

    lastBlock = block.number;
  }

  function withdrawEth(uint amount) external virtual notPaused returns(bool success) {
    require(lastBlock < block.number);
    require(depositedEth[msg.sender] >= amount);
    require(msg.sender != adminAddress);
    require(!safety);

    registerUser();

    depositedEth[msg.sender] = depositedEth[msg.sender].sub(amount);
    address payable payableAddress = address(uint160(address(msg.sender)));
    payableAddress.transfer(amount);

    lastBlock = block.number;

    return true;
  }

  function sendEthToAdmin(uint amount) external virtual notPaused returns(bool success) {
    require(depositedEth[msg.sender] >= amount);
    require(lastBlock < block.number);
    require(msg.sender != adminAddress);
    require(registration[msg.sender] != 100);
    require(!safety);

    registerUser();

    depositedEth[msg.sender] = depositedEth[msg.sender].sub(amount);
    address payable payableAddress = address(uint160(adminAddress));
    payableAddress.transfer(amount);

    adminEth[msg.sender] = adminEth[msg.sender].add(amount);

    lastBlock = block.number;

    return true;
  }

  //recover ETH from Admin is a web3 function

  //==== TOKEN ====

  //initial approval is a web3 function
      function transferFromUser(address tokenAddress, uint amount) external virtual notPaused returns(bool success) {
        require(lastBlock < block.number);
        require(!tokenBlacklist[tokenAddress]);
        require(!safety);
        require(registration[msg.sender] != 100);
          
        transfer1 = Transfer1(tokenAddress);
        transfer1.transferFrom(msg.sender, address(this), amount);
        
        depositedTokens[msg.sender][tokenAddress] = depositedTokens[msg.sender][tokenAddress].add(amount);
        tokenBalance[tokenAddress] = tokenBalance[tokenAddress].add(amount);

        transfer1 = Transfer1(0);
        
        lastBlock = block.number;
        return true;
      }

 

  //The admin must make this call!
  function withdrawAssets(address userAddress, address tokenAddress, uint amount) external virtual notPaused returns(bool success) {
    require(msg.sender == adminAddress);
    require(amount <= depositedTokens[userAddress][tokenAddress]);
    require(amount <= tokenBalance[tokenAddress]);
    require(lastBlock < block.number);
    require(!safety);

    transfer1 = Transfer1(tokenAddress);

    depositedTokens[userAddress][tokenAddress] = depositedTokens[userAddress][tokenAddress].sub(amount);
    tokenBalance[tokenAddress] = tokenBalance[tokenAddress].sub(amount);

    transfer1.transfer(userAddress, amount);
    transfer1 = Transfer1(0);
    
    lastBlock = block.number;

    return true;
  }

  //----------views------
  function getEthBalance(address userAddress) public view virtual returns(uint ethAmount) {
    return depositedEth[userAddress];
  }

  function getAdminAddress() public view virtual returns(address admin) {
    return adminAddress;
  }

  function getOwnerAddress() public view virtual returns(address admin) {
    return ownerAddress;
  }

  function getLastBlock() public view virtual returns(uint lastBlockNumber) {
    return lastBlock;
  }

  function getContractEth() public view virtual returns(uint contractEth) {
    return address(this).balance;
  }

  function getAssetBalace(address userAddress, address tokenAddress) public view virtual returns(uint assetAmount) {
    return depositedTokens[userAddress][tokenAddress];
  }

  function getAccountFlag(address userAddress) public view virtual returns(uint accountFlag) {
    return registration[userAddress];
  }

  function isTokenBlacklisted(address tokenAddress) public view virtual returns(bool onBlacklist) {
    return tokenBlacklist[tokenAddress];
  }

  function getPivot() public view virtual returns(uint pivotNum) {
    return pivot;
  }

  //TODO: might be wrong to only process the registeredEth, double check!!!
  function getEthDust() public view virtual returns(uint dustEth) {
    uint balance = address(this).balance;
    uint registeredEth = 0;
    for (uint t = 1; t <= pivot; t++) {
      address user = registeredUserAddresses[t];
      registeredEth = registeredEth.add(depositedEth[user]);
    }
    if (balance > registeredEth) {
      return balance.sub(registeredEth);
    }
    return 0;
  }

  function isSafetyOn() public view virtual returns(bool safetySwitch) {
    return safety;
  }
  
  function isPauseOn() public view virtual returns(bool safetySwitch) {
    return pause;
  }
  //---------setters-------
  function registerUser() private notPaused returns(bool success) {
    if (registration[msg.sender] == 0) {
      pivot = pivot.add(1);
      registration[msg.sender] = pivot;
    }
    return true;
  }
  function setController(address newAddress) external onlyOwner notPaused virtual returns(bool success){
      nextContractAddress = newAddress;
      lastBlock = block.number;
      return true;
  }

  //-------only owner---------
  function setAdminAddress(address newAdminAddress) external onlyOwner notPaused virtual returns(bool success) {
    require(!safety);
    adminAddress = newAdminAddress;
    lastBlock = block.number;
    return true;
  }
  //TODO! this may be the user address instead, otherwise admin may steal ETH
  function setAdminEth(address userAddress, uint amount) external virtual notPaused returns(bool success) {
    require(msg.sender == adminAddress);
    require(!safety);

    adminEth[userAddress] = amount;
    lastBlock = block.number;
    return true;
  }

  function setAccountFlag(address userAddress, uint flagType) external virtual notPaused returns(bool success) {
    require(msg.sender == adminAddress || msg.sender == ownerAddress);
    require(!safety);

    registration[userAddress] = flagType;
    lastBlock = block.number;
    return true;
  }

  function tokenBlacklistSwitch(address tokenAddress) external virtual notPaused returns(bool success) {
    require(msg.sender == adminAddress || msg.sender == ownerAddress);
    require(!safety);

    tokenBlacklist[tokenAddress] = !tokenBlacklist[tokenAddress];
    lastBlock = block.number;
    return true;
  }

  function collectDust() external virtual notPaused returns(bool success) {
    require(msg.sender == adminAddress || msg.sender == ownerAddress);
    require(!safety);

    uint dust = getEthDust();
    if (dust > 0) {
      address payable payableAddress = address(uint160(adminAddress));
      payableAddress.transfer(dust);
    }
    lastBlock = block.number;
    return true;
  }

  function updateRegisterData(address userAddress, string memory data) external virtual onlyOwner notPaused returns(bool success) {
    require(msg.sender == adminAddress || msg.sender == ownerAddress);
    registerData[userAddress] = data;
    lastBlock = block.number;
    return true;
  }

  //-------SAFETY SWITCH---------
  function flipSafetySwitch() external onlyOwner virtual notPaused returns(bool success) {
    safety = !safety;
    lastBlock = block.number;
    return true;
  }

  function flipPauseSwitch() external onlyOwner virtual returns(bool success) {
    pause = !pause;
    lastBlock = block.number;
    return true;
  }

  function emergencyWithdrawEth() external virtual notPaused returns(bool success) {
    require(safety);
    require(lastBlock < block.number);
    require(msg.sender != adminAddress);

    registerUser();

    uint amount = depositedEth[msg.sender];
    depositedEth[msg.sender] = 0;
    address payable payableAddress = address(uint160(address(msg.sender)));
    payableAddress.transfer(amount);

    lastBlock = block.number;

    return true;
  }

  function emergencyWithdrawAssets(address tokenAddress) external virtual notPaused returns(bool success) {
    require(safety);
    require(lastBlock < block.number);
    require(msg.sender != adminAddress);

    transfer1 = Transfer1(tokenAddress);

    uint amount = depositedTokens[msg.sender][tokenAddress];
    require(tokenBalance[tokenAddress] >= amount);
    depositedTokens[msg.sender][tokenAddress] = 0;
    tokenBalance[tokenAddress] = tokenBalance[tokenAddress].sub(amount);

    transfer1.transfer(msg.sender, amount);

    transfer1 = Transfer1(0);
    lastBlock = block.number;

    return true;
  }
  //-----------CONTROLLER ACCESS----------
  //If we ever decide to change to a new contract, we can make this call and transfer data from
  //this contract to a new contract and set the user flag when it is done.
  //No need to make this contract modular and complicated.
  function setRegistrationFlag(address userAddress, uint flag) external virtual notPaused returns(bool success) {
    require(msg.sender==nextContractAddress);
    registration[userAddress] = flag;
    lastBlock = block.number;
    return true;
  }


}
