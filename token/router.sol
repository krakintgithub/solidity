

// SPDX-License-Identifier: MIT

pragma solidity = 0.7 .0;

abstract contract Context {
	function _msgSender() internal view virtual returns(address payable) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns(bytes memory) {
		this;
		return msg.data;
	}
}

contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor() {
		address msgSender = _msgSender();
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
	}

	function owner() public view returns(address) {
		return _owner;
	}

	modifier onlyOwner() {
		require(_owner == _msgSender(), "Ownable: caller is not the owner");
		_;
	}

	function renounceOwnership() public virtual onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

interface IERC20 {
	function currentCoreContract() external view returns(address routerAddress);

	function currentTokenContract() external view returns(address routerAddress);

	function getExternalContractAddress(string memory contractName) external view returns(address routerAddress);

	function callRouter(string memory route, address[2] memory addressArr, uint[2] memory uintArr) external returns(bool success);

	function _callRouter(string memory route, address[3] memory addressArr, uint[3] memory uintArr) external returns(bool success);

	function extrenalRouterCall(string memory route, address[2] memory addressArr, uint[2] memory uintArr) external returns(bool success);

}

abstract contract Core {

	function transfer(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);

	function approve(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);

	function increaseAllowance(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);

	function decreaseAllowance(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);

	function transferFrom(address[3] memory addressArr, uint[3] memory uintArr) external virtual returns(bool success);

	function mint(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);

	function burn(address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);

}

//============================================================================================
// MAIN CONTRACT 
//============================================================================================

contract Router is Ownable, IERC20 {

	address public tokenContract;
	address public coreContract;
	Core private core;

	mapping(string => address) public externalContracts; //for non-core functions

	//============== CORE FUNCTIONS START HERE ==================================================
	//These functions should never change when introducing a new version of a router.
	//Router is expected to constantly change, and the code should be written under 
	//the "NON-CORE FUNCTIONS TO BE CODED BELOW".

	function equals(string memory a, string memory b) internal view virtual returns(bool isEqual) {
		return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
	}

	function currentTokenContract() override external view virtual returns(address routerAddress) {
		return tokenContract;
	}

	function currentCoreContract() override external view virtual returns(address routerAddress) {
		return coreContract;
	}

	function getExternalContractAddress(string memory contractName) override external view virtual returns(address routerAddress) {
		return externalContracts[contractName];
	}

	//function is not needed if token address is hard-coded in a constructor
	function setNewTokenContract(address newTokenAddress) onlyOwner public virtual returns(bool success) {
		tokenContract = newTokenAddress;
		return true;
	}

	function setNewCoreContract(address newCoreAddress) onlyOwner public virtual returns(bool success) {
		coreContract = newCoreAddress;
		core = Core(coreContract);
		return true;
	}

	function setNewExternalContract(string memory contractName, address newContractAddress) onlyOwner public virtual returns(bool success) {
		externalContracts[contractName] = newContractAddress;
		return true;
	}

	function callRouter(string memory route, address[2] memory addressArr, uint[2] memory uintArr) override external virtual returns(bool success) {
		require(msg.sender == tokenContract, "at: router.sol | contract: Router | method: callRouter | message: Must be called by the registered Token contract");

		if (equals(route, "transfer")) {
			core.transfer(addressArr, uintArr);
		} else if (equals(route, "approve")) {
			core.approve(addressArr, uintArr);
		} else if (equals(route, "increaseAllowance")) {
			core.increaseAllowance(addressArr, uintArr);
		} else if (equals(route, "decreaseAllowance")) {
			core.decreaseAllowance(addressArr, uintArr);
		}
		return true;
	}

	function _callRouter(string memory route, address[3] memory addressArr, uint[3] memory uintArr) override external virtual returns(bool success) {

		require(msg.sender == tokenContract, "at: router.sol | contract: Router | method: _callRouter | message: Must be called by the registered Token contract");

		if (equals(route, "transferFrom")) {
			core.transferFrom(addressArr, uintArr);
		}
		return true;
	}
	//============== CORE FUNCTIONS END HERE ==================================================


	//=============== NON-CORE ROUTES TO BE CODED BELOW =======================================
        // This code is a subject to a change, should we decide to alter anything.
        // We can also design another external router, possibilities are infinite.
    
	function extrenalRouterCall(string memory route, address[2] memory addressArr, uint[2] memory uintArr) override external virtual returns(bool success) {
		if (equals(route, "mint")) {
			require(externalContracts["mint"] == msg.sender, "at: router.sol | contract: Router | method: extrenalRouterCall | message: Must be called by the registered external 'mint' contract");
			core.mint(addressArr, uintArr);
		} else if (equals(route, "burn")) {
			require(externalContracts["burn"] == msg.sender, "at: router.sol | contract: Router | method: extrenalRouterCall | message: Must be called by the registered external 'burn' contract");
			core.burn(addressArr, uintArr);
		}

		return true;
	}

}

