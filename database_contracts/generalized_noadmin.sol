//THIS IS NOT A CONCTACT!  Only a pattern to use if/when necessary, for example, if we want database of string type, replace !@#$% with "string[2^256]" then replace !@#$ with "string"

// SPDX-License-Identifier: MIT

pragma solidity >= 0.5 .0 < 0.8 .0;


contract Database
{

	mapping(address => mapping(uint => !@#$%[2^256])) dataArray;


	//--------------Data Read functions----------------------------------------

	function getDataValue(uint id, uint x)  public view returns(!@#$% memory data)
	{
		return dataArray[msg.sender][id][x];
	}

	function getDataValue(uint id, uint x, uint y) public view returns(!@#$ data)
	{
		return dataArray[msg.sender][id][x][y];
	}

	//--------------Data Write/Update functions--------------------------------

	function insert(uint id, uint x, uint y, !@#$ data) public returns(bool success)
	{
		dataArray[msg.sender][id][x][y] = data;
		return true;
	}

	function insert(uint id, uint x, !@#$% memory y) public returns(bool success)
	{
		dataArray[msg.sender][id][x] = y;
		return true;
	}
	
}
