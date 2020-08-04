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
	
	function getDataValue(uint id) public view returns(string[2^256][2^256] memory data)
	{
		return dataArray[msg.sender][id];
	}
	function getRow(uint id, uint row, uint startIndex, uint endIndex) public view returns(string[] memory data){
	    require(startIndex<=endIndex);
	    uint arrSize = startIndex-endIndex;
        data = new string[](arrSize);
        for(uint i=0;i<arrSize;i++){
            data[i] = dataArray[msg.sender][id][startIndex+i][row];
        }
        return data;
	}
	function getColumn(uint id, uint column, uint startIndex, uint endIndex) public view returns(string[] memory data){
	    require(startIndex<=endIndex);
	    uint arrSize = startIndex-endIndex;
        data = new string[](arrSize);
        for(uint i=0;i<arrSize;i++){
            data[i] = dataArray[msg.sender][id][column][startIndex+i];
        }
        return data;
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
	
	function insert(uint id, string[2^256][2^256] memory data) public returns(bool success)
	{
		dataArray[msg.sender][id] = data;
		return true;
	}
	
	
}
