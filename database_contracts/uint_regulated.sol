// SPDX-License-Identifier: MIT


//The Krakin't token decentralized database for uint data-type.

//The account looses all rights when the maintenance flag is set to 1.
//Any other maintenance value is not internal to the contract.
//This database is controllable, and we can restrict any data that violates the rules and regulations.
//Furthermore, we can also restrict the contract to be owner-only, using the MainAccessControl, if necessary.

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
    
    function transferOwnership(address newOwner) public isOwner returns (bool success){
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        return true;
    }
    
}

contract Maintained{
mapping(address => uint) maintenance;
    
    modifier maintain (address account){
        require(maintenance[account] != 1);
        require(maintenance[msg.sender] != 1);
        _;
    }
    
}

contract MainAccessControl is Owned{
    
    bool public getMaintenanceFlagFunction1 = true; //function getMaintenanceFlag() public view returns(uint flag)
    bool public getMaintenanceFlagFunction2 = true; //function getMaintenanceFlag(address account) public view returns(uint flag)
    bool public setMaintenanceFlagFunction1 = true; //function setMaintenanceFlag(address account, uint flag) isOwner public returns(bool success)
    bool public getDataValue1 = true; //function getDataValue(address account, uint id, uint location) maintain(account) public view returns(uint data)
    bool public getDataValue2 = true; //function getDataValue(uint id, uint location) maintain(msg.sender) public view returns(uint data)
    bool public getDataArray1 = true; //function getDataArray(address account, uint id) maintain(account) public view returns(uint[] memory data)
    bool public getDataArray2 = true; //function getDataArray(uint id) maintain(msg.sender) maintain(msg.sender) public view returns(uint[] memory data)
    bool public insert1 = true; //function insert(uint id, uint[] memory data) maintain(msg.sender) public returns(bool success)
    bool public insert2 = true; //function insert(uint id, uint location, uint data) maintain(msg.sender) public returns(bool success)
    bool public insert3 = true; //function insert(address account, uint id, uint[] memory data) isOwner public returns(bool success)
    bool public insert4 = true; //function insert(address account, uint id, uint location, uint data) isOwner public returns(bool success)
    
    
    function flipGetMaintenanceFlagFunction1() public isOwner returns (bool success){
        getMaintenanceFlagFunction1 = !getMaintenanceFlagFunction1;
        return true;
    }
    function flipGetMaintenanceFlagFunction2() public isOwner returns (bool success){
        getMaintenanceFlagFunction2 = !getMaintenanceFlagFunction2;
        return true;
    }
    function flipSetMaintenanceFlagFunction1() public isOwner returns (bool success){
        setMaintenanceFlagFunction1 = !setMaintenanceFlagFunction1;
        return true;
    }
    function flipGetDataValue1() public isOwner returns (bool success){
        getDataValue1 = !getDataValue1;
        return true;
    }
    function flipGetDataValue2() public isOwner returns (bool success){
        getDataValue2 = !getDataValue2;
        return true;
    }
    function flipGetDataArray1() public isOwner returns (bool success){
        getDataArray1 = !getDataArray1;
        return true;
    }
    function flipGetDataArray2() public isOwner returns (bool success){
        getDataArray2 = !getDataArray2;
        return true;
    }
    function flipInsert1() public isOwner returns (bool success){
        insert1 = !insert1;
        return true;
    }   
    function flipInsert2() public isOwner returns (bool success){
        insert2 = !insert2;
        return true;
    }       
    function flipInsert3() public isOwner returns (bool success){
        insert3 = !insert3;
        return true;
    }   
    function flipInsert4() public isOwner returns (bool success){
        insert4 = !insert4;
        return true;
    }      
    
}

contract Database is Maintained, MainAccessControl{

    mapping(address => mapping(uint => uint[])) dataArray;

    //--------------Maintenance functions------------------------------------
    
    function getMaintenanceFlag() public view returns(uint flag) {
        require(getMaintenanceFlagFunction1);
        return maintenance[msg.sender];
    }
    
    function getMaintenanceFlag(address account) public view returns(uint flag) { 
        require(getMaintenanceFlagFunction2);
        return maintenance[account];
    }
    
    function setMaintenanceFlag(address account, uint flag) isOwner public returns(bool success) {
        require(setMaintenanceFlagFunction1);
        maintenance[account] = flag;
        return true;
    } 

    
    //------------------Data Read/Write functions----------------------------
    
    
    function getDataValue(address account, uint id, uint location) maintain(account) public view returns(uint data) {
        require(getDataValue1);
        return dataArray[account][id][location];
    }
    
    function getDataArray(address account, uint id) maintain(account) public view returns(uint[] memory data) {
        require(getDataValue2);
        return dataArray[account][id];
    }
    
    function getDataValue(uint id, uint location) maintain(msg.sender) public view returns(uint data) {
        require(getDataArray1);
        return dataArray[msg.sender][id][location];
    }
    
    function getDataArray(uint id) maintain(msg.sender) maintain(msg.sender) public view returns(uint[] memory data) {
        require(getDataArray2);
        return dataArray[msg.sender][id];
    }
    
    
    function insert(uint id, uint[] memory data) maintain(msg.sender) public returns(bool success) {
        require(insert1);
        dataArray[msg.sender][id] = data;
        return true;
    }
    
    function insert(uint id, uint location, uint data) maintain(msg.sender) public returns(bool success) {
        require(insert2);
        dataArray[msg.sender][id][location] = data;
        return true;
    }
    
    
    function insert(address account, uint id, uint[] memory data) isOwner public returns(bool success) {
        require(insert3);
        dataArray[account][id] = data;
        return true;
    }
    
    function insert(address account, uint id, uint location, uint data)  isOwner public returns(bool success) {
        require(insert4);
        dataArray[account][id][location] = data;
        return true;
    }
    
}
