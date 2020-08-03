// SPDX-License-Identifier: MIT

pragma solidity >= 0.5 .0 < 0.8 .0;


contract Database
{

	mapping(address => mapping(uint => string[2^256][2^256])) dataArray;


	//--------------Data Read functions----------------------------------------

	function getDataValue(uint id, uint x, uint y) public view returns(string memory data)
	{
		return dataArray[msg.sender][id][x][y];
	}

	//--------------Data Write/Update functions--------------------------------

	function insert(uint id, uint x, uint y, string memory data) public returns(bool success)
	{
		dataArray[msg.sender][id][x][y] = data;
		return true;
	}

	
}

