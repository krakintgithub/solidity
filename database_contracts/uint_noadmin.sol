// SPDX-License-Identifier: MIT

pragma solidity >= 0.5 .0 < 0.8 .0;


contract Database
{

	mapping(address => mapping(uint => uint[][])) dataArray;


	//--------------Data Read functions----------------------------------------

	function getDataValue(uint id, uint x)  public view returns(uint[] memory data)
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

	function insert(uint id, uint x, uint[] memory y) public returns(bool success)
	{
		dataArray[msg.sender][id][x] = y;
		return true;
	}
	
}
