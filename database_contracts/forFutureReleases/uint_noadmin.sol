// SPDX-License-Identifier: MIT

pragma solidity >= 0.5 .0 < 0.8 .0;


contract Schema
{

	mapping(address => mapping(uint => uint[2^256][2^256])) dataArray;


	//--------------Data Read functions----------------------------------------

	function getDataValue(uint id, uint x)  public view returns(uint[2^256] memory data)
	{
		return dataArray[msg.sender][id][x];
	}

	function getDataValue(uint id, uint x, uint y) public view returns(uint data)
	{
		return dataArray[msg.sender][id][x][y];
	}

	//--------------Data Write/Update functions--------------------------------

	function insert(uint id, uint x, uint y, uint data) public returns(bool success)
	{
		dataArray[msg.sender][id][x][y] = data;
		return true;
	}

	function insert(uint id, uint x, uint[2^256] memory y) public returns(bool success)
	{
		dataArray[msg.sender][id][x] = y;
		return true;
	}
	
}

