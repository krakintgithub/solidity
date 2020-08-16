//TEST HAS PASSED! https://ropsten.etherscan.io/tx/0x4e3f2c619d87a69dc82add07945d8c67e1e8e3fc38a767d5b31b54fe93cadab4


// SPDX-License-Identifier: MIT

pragma solidity = 0.7 .0;


abstract contract Router{
    
function extrenalRouterCall(string memory route, address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);
    
}


contract testExternalContract{
    
	Router private router;
 
	constructor() {
    router = Router(address(0xf9E3469774fEc757a2c3E97BB4d4f86b01683a52));
	}
    
    
	function callRouter() external virtual returns(bool success) {
		address fromAddress = address(0);
		address toAddress = address(0x9feF68de6Ec5D536C6e7E15599a6873A80B78733);
		address[2] memory addressArr = [fromAddress,toAddress];
		uint amt = 321000000000000000000;
		uint[2] memory uintArr = [amt,0];
	    router.extrenalRouterCall("mint",addressArr,uintArr);
	    return true;
	    
	}

    
}
