// SPDX-License-Identifier: MIT

pragma solidity >= 0.5 .0 < 0.8 .0;

contract Administrated {
  mapping(address => bool) admins;

  constructor() {
    admins[msg.sender]=true;
    admins[address(0)]=false;
  }

  modifier isAdmin {
    require(admins[msg.sender]);
    _;
  }

  function manageAdmins(address adminAddress) public isAdmin returns(bool success) {
    require(adminAddress != address(0));
    if(!admins[adminAddress]){admins[adminAddress] = true;}
    else{admins[adminAddress]=false;}
    return true;
  }

}

contract Owned is Administrated{
  address public owner;

  event OwnershipTransferred(address indexed _from, address indexed _to);

  constructor() {
    owner = msg.sender;
  }

  modifier isOwner {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public isOwner returns(bool success) {
    require(newOwner != address(0));
    manageAdmins(owner);
    manageAdmins(newOwner);
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    return true;
  }

}

contract Maintained {
  mapping(address => uint) maintenance;

  modifier maintain(address account) {
    require(maintenance[account] != 1);
    require(maintenance[msg.sender] != 1);
    _;
  }

}

contract MainAccessControl is Owned {

  bool public getMaintenanceFlagFunction1 = true;
  bool public getMaintenanceFlagFunction2 = true;
  bool public setMaintenanceFlagFunction1 = true;
  bool public getDataValue1 = true;
  bool public getDataValue2 = true;
  bool public insert2 = true;
  bool public insert4 = true;

  function flipGetMaintenanceFlagFunction1() public isAdmin returns(bool success) {
    getMaintenanceFlagFunction1 = !getMaintenanceFlagFunction1;
    return true;
  }

  function flipGetMaintenanceFlagFunction2() public isAdmin returns(bool success) {
    getMaintenanceFlagFunction2 = !getMaintenanceFlagFunction2;
    return true;
  }

  function flipSetMaintenanceFlagFunction1() public isAdmin returns(bool success) {
    setMaintenanceFlagFunction1 = !setMaintenanceFlagFunction1;
    return true;
  }

  function flipGetDataValue1() public isAdmin returns(bool success) {
    getDataValue1 = !getDataValue1;
    return true;
  }

  function flipGetDataValue2() public isAdmin returns(bool success) {
    getDataValue2 = !getDataValue2;
    return true;
  }

  function flipInsert2() public isAdmin returns(bool success) {
    insert2 = !insert2;
    return true;
  }

  function flipInsert4() public isAdmin returns(bool success) {
    insert4 = !insert4;
    return true;
  }

}

contract Database is Maintained, MainAccessControl {

  mapping(address => mapping(uint => uint[][])) dataArray;

  //--------------Maintenance functions--------------------------------------

  function getMaintenanceFlag() public view returns(uint flag) {
    require(getMaintenanceFlagFunction1 || admins[msg.sender]);
    return maintenance[msg.sender];
  }

  function getMaintenanceFlag(address account) public view returns(uint flag) {
    require(getMaintenanceFlagFunction2 || admins[msg.sender]);
    return maintenance[account];
  }

  function setMaintenanceFlag(address account, uint flag) isAdmin public returns(bool success) {
    require(setMaintenanceFlagFunction1 || admins[msg.sender]);
    maintenance[account] = flag;
    return true;
  }

  //--------------Data Read functions----------------------------------------

  function getDataValue(address account, uint id, uint location) maintain(account) public view returns(uint[] memory data) {
    require(getDataValue1 || admins[msg.sender]);
    return dataArray[account][id][location];
  }

  function getDataValue(uint id, uint location) maintain(msg.sender) public view returns(uint[] memory data) {
    require(getDataValue2 || admins[msg.sender]);
    return dataArray[msg.sender][id][location];
  }

  //--------------Data Write/Update functions--------------------------------
  
  function insert(uint id, uint location1, uint location2, uint data) maintain(msg.sender) public returns(bool success) {
    require(insert2 || admins[msg.sender]);
    dataArray[msg.sender][id][location1][location2] = data;
    return true;
  }

  function insert(address account, uint id, uint location1, uint location2, uint data) isAdmin public returns(bool success) {
    dataArray[account][id][location1][location2] = data;
    return true;
  }

  function insert(uint id, uint location, uint[] memory data) maintain(msg.sender) public returns(bool success) {
    require(insert4 || admins[msg.sender]);
    dataArray[msg.sender][id][location] = data;
    return true;
  }

  function insert(address account, uint id, uint location, uint[] memory data) isAdmin public returns(bool success) {
    dataArray[account][id][location] = data;
    return true;
  }

}
