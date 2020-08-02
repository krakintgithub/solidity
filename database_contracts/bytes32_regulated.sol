// SPDX-License-Identifier: MIT

pragma solidity >= 0.5 .0 < 0.8 .0;

contract Owned {
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
  bool public getDataArray1 = true;
  bool public getDataArray2 = true;
  bool public insert1 = true;
  bool public insert2 = true;
  bool public insert3 = true;
  bool public insert4 = true;

  function flipGetMaintenanceFlagFunction1() public isOwner returns(bool success) {
    getMaintenanceFlagFunction1 = !getMaintenanceFlagFunction1;
    return true;
  }

  function flipGetMaintenanceFlagFunction2() public isOwner returns(bool success) {
    getMaintenanceFlagFunction2 = !getMaintenanceFlagFunction2;
    return true;
  }

  function flipSetMaintenanceFlagFunction1() public isOwner returns(bool success) {
    setMaintenanceFlagFunction1 = !setMaintenanceFlagFunction1;
    return true;
  }

  function flipGetDataValue1() public isOwner returns(bool success) {
    getDataValue1 = !getDataValue1;
    return true;
  }

  function flipGetDataValue2() public isOwner returns(bool success) {
    getDataValue2 = !getDataValue2;
    return true;
  }

  function flipGetDataArray1() public isOwner returns(bool success) {
    getDataArray1 = !getDataArray1;
    return true;
  }

  function flipGetDataArray2() public isOwner returns(bool success) {
    getDataArray2 = !getDataArray2;
    return true;
  }

  function flipInsert1() public isOwner returns(bool success) {
    insert1 = !insert1;
    return true;
  }

  function flipInsert2() public isOwner returns(bool success) {
    insert2 = !insert2;
    return true;
  }

  function flipInsert3() public isOwner returns(bool success) {
    insert3 = !insert3;
    return true;
  }

  function flipInsert4() public isOwner returns(bool success) {
    insert4 = !insert4;
    return true;
  }

}

contract Database is Maintained, MainAccessControl {

  mapping(address => mapping(uint => bytes32[])) dataArray;

  //--------------Maintenance functions--------------------------------------

  function getMaintenanceFlag() public view returns(uint flag) {
    require(getMaintenanceFlagFunction1 || msg.sender==owner);
    return maintenance[msg.sender];
  }

  function getMaintenanceFlag(address account) public view returns(uint flag) {
    require(getMaintenanceFlagFunction2 || msg.sender==owner);
    return maintenance[account];
  }

  function setMaintenanceFlag(address account, uint flag) isOwner public returns(bool success) {
    require(setMaintenanceFlagFunction1 || msg.sender==owner);
    maintenance[account] = flag;
    return true;
  }

  //--------------Data Read functions----------------------------------------

  function getDataValue(address account, uint id, uint location) maintain(account) public view returns(bytes32 data) {
    require(getDataValue1 || msg.sender==owner);
    return dataArray[account][id][location];
  }

  function getDataArray(address account, uint id) maintain(account) public view returns(bytes32[] memory data) {
    require(getDataArray1 || msg.sender==owner);
    return dataArray[account][id];
  }

  function getDataValue(uint id, uint location) maintain(msg.sender) public view returns(bytes32 data) {
    require(getDataValue2 || msg.sender==owner);
    return dataArray[msg.sender][id][location];
  }

  function getDataArray(uint id) maintain(msg.sender) maintain(msg.sender) public view returns(bytes32[] memory data) {
    require(getDataArray2 || msg.sender==owner);
    return dataArray[msg.sender][id];
  }

  //--------------Data Write/Update functions--------------------------------

  function insert(uint id, bytes32[] memory data) maintain(msg.sender) public returns(bool success) {
    require(insert1 || msg.sender==owner);
    dataArray[msg.sender][id] = data;
    return true;
  }

  function insert(uint id, uint location, bytes32 data) maintain(msg.sender) public returns(bool success) {
    require(insert2 || msg.sender==owner);
    dataArray[msg.sender][id][location] = data;
    return true;
  }

  function insert(address account, uint id, bytes32[] memory data) isOwner public returns(bool success) {
    require(insert3 || msg.sender==owner);
    dataArray[account][id] = data;
    return true;
  }

  function insert(address account, uint id, uint location, bytes32 data) isOwner public returns(bool success) {
    require(insert4 || msg.sender==owner);
    dataArray[account][id][location] = data;
    return true;
  }

}