// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity >= 0.5 .0 < 0.8 .0;


contract Schema
{

	mapping(address => mapping(uint => string[2^256][2^256])) dataArray;


	//--------------Data Read functions----------------------------------------

	function getDataValue(uint id, uint x, uint y) public view returns(string memory data)
	{
		return dataArray[msg.sender][id][x][y];
	}
	
	function getDataValue(uint id, uint x) public view returns(string[2^256] memory data)
	{
		return dataArray[msg.sender][id][x];
	}

	//--------------Data Write/Update functions--------------------------------

	function insert(uint id, uint x, uint y, string memory data) public returns(bool success)
	{
		dataArray[msg.sender][id][x][y] = data;
		return true;
	}

	function insert(uint id, uint x, string[2^256] memory data) public returns(bool success)
	{
		dataArray[msg.sender][id][x] = data;
		return true;
	}
	
	
}



