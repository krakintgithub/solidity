// SPDX-License-Identifier: MIT

pragma solidity >= 0.5 .0 < 0.8 .0;

contract Administrated
{
	mapping(address => bool) admins;
	bool public runAdminConstrOnce = true;

	constructor()
	{
		if(runAdminConstrOnce){
		admins[msg.sender] = true;
		admins[address(0)] = false;
		runAdminConstrOnce=false;
		}
	}

	modifier isAdmin
	{
		require(admins[msg.sender]);
		_;
	}

	function manageAdmins(address adminAddress) public isAdmin returns(bool success)
	{
		require(adminAddress != address(0));
		if (!admins[adminAddress])
		{
			admins[adminAddress] = true;
		}
		else
		{
			admins[adminAddress] = false;
		}
		return true;
	}
	
	function isAdminAccount(address account) public view returns(bool value)
	{
		return admins[account];
	}
	
	
}

contract Owned is Administrated
{
	address public owner;
	bool public runOwnedConstrOnce = true;

	event  OwnershipTransferred(address indexed _from, address indexed _to);

	constructor()
	{
	    if(runOwnedConstrOnce){
		owner = msg.sender;
	    runOwnedConstrOnce = false;
	    }
	}

	modifier isOwner
	{
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address newOwner) public isOwner returns(bool success)
	{
		require(newOwner != address(0));
		if(admins[owner]) manageAdmins(owner);
		if(!admins[newOwner]) manageAdmins(newOwner);
		emit OwnershipTransferred(owner, newOwner);
		owner = newOwner;
		return true;
	}
}

contract Maintained is Owned
{
	mapping(address => uint) maintenance;

	modifier maintain(address account)
	{
		require(maintenance[account] != 1);
		require(maintenance[msg.sender] != 1);
		_;
	}

	modifier allowAdmins(bool value, address account)
	{
		require(value || admins[account]);
		_;
	}
}

contract MainAccessControl is Maintained
{

	bool public getMaintenanceFlagFunction1 = true;
	bool public getMaintenanceFlagFunction2 = true;
	bool public getDataValue1 = true;
	bool public getDataValue2 = true;
	bool public insert1 = true;

	function flipGetMaintenanceFlagFunction1() public isAdmin returns(bool success)
	{
		getMaintenanceFlagFunction1 = !getMaintenanceFlagFunction1;
		return true;
	}

	function flipGetMaintenanceFlagFunction2() public isAdmin returns(bool success)
	{
		getMaintenanceFlagFunction2 = !getMaintenanceFlagFunction2;
		return true;
	}

	function flipGetDataValue1() public isAdmin returns(bool success)
	{
		getDataValue1 = !getDataValue1;
		return true;
	}

	function flipGetDataValue2() public isAdmin returns(bool success)
	{
		getDataValue2 = !getDataValue2;
		return true;
	}

	function flipInsert1() public isAdmin returns(bool success)
	{
		insert1 = !insert1;
		return true;
	}
	
	//--------------Maintenance functions--------------------------------------

	function getMaintenanceFlag() 
	allowAdmins(getMaintenanceFlagFunction1, msg.sender) public view returns(uint flag)
	{
		return maintenance[msg.sender];
	}

	function getMaintenanceFlag(address account) 
	allowAdmins(getMaintenanceFlagFunction2, msg.sender) public view returns(uint flag)
	{
		return maintenance[account];
	}

	function setMaintenanceFlag(address account, uint flag) isAdmin public returns(bool success)
	{
		maintenance[account] = flag;
		return true;
	}


}

contract Schema is MainAccessControl
{

	mapping(address => mapping(string => string)) dataArray;

	//--------------Data Read functions----------------------------------------
	

	function getDataValue(string memory key)  
	maintain(msg.sender) allowAdmins(getDataValue1, msg.sender) 
	public view returns(string memory data)
	{
		return dataArray[msg.sender][key];
	}
	
	function getDataValue(address account, string memory key)  
	maintain(account) allowAdmins(getDataValue2, msg.sender) 
	public view returns( string memory data)
	{
		return dataArray[account][key];
	}

	//--------------Data Write/Update functions--------------------------------
	
	function insert(string memory key, string memory data) 
	maintain(msg.sender)
	allowAdmins(insert1, msg.sender)
	public returns(bool success)
	{
		dataArray[msg.sender][key] = data;
		return true;
	}
	
	function insert(address account, string memory key, string memory data) isAdmin public returns(bool success)
	{
		dataArray[account][key] = data;
		return true;
	}

}

