// SPDX-License-Identifier: MIT

pragma solidity >= 0.5 .0 < 0.8 .0;


contract Database
{

	mapping(address => mapping(uint => string[][])) dataArray;


	//--------------Data Read functions----------------------------------------

	function getDataValue(uint id, uint x)  public view returns(string[] memory data)
	{
		return dataArray[msg.sender][id][x];
	}

	function getDataValue(uint id, uint x, uint y) public view returns(string data)
	{
		return dataArray[msg.sender][id][x][y];
	}

	//--------------Data Write/Update functions--------------------------------

	function insert(uint id, uint x, uint y, string data) public returns(bool success)
	{
		dataArray[msg.sender][id][x][y] = data;
		return true;
	}

	function insert(uint id, uint x, string[] memory y) public returns(bool success)
	{
		dataArray[msg.sender][id][x] = y;
		return true;
	}
	
}
