// SPDX-License-Identifier: MIT


//All strings are to be placed as JSON format, to keep the low costs, we can use the gz, bzip2 or deflate to compress.
//Compress and Decompress is done externally

pragma solidity >= 0.5 .0 < 0.8 .0;


contract Schema
{
	mapping(address => mapping(string => string)) dataArray;

	//--------------Data Read functions----------------------------------------
	function getDataValue(string memory key) public view returns(string memory data)
	{
		return dataArray[msg.sender][key];
	}

	//--------------Data Write/Update functions--------------------------------
	function insert(string memory key, string memory data) public returns(bool success)
	{
		dataArray[msg.sender][key] = data;
		return true;
	}
	
}
