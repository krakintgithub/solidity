## Functions and their routes

### router.sol

#### Core

##### Functions
```js
transfer(address[2] memory addressArr, uint[2] memory uintArr)
```
Executes the transfer function of the Core contract


```js
approve(address[2] memory addressArr, uint[2] memory uintArr)
```
Executes the approve function of the Core contract


```js
increaseAllowance(address[2] memory addressArr, uint[2] memory uintArr)
```
Executes the increaseAllowance function of the Core contract


```js
decreaseAllowance(address[2] memory addressArr, uint[2] memory uintArr)
```
Executes the decreaseAllowance function of the Core contract


```js
transferFrom(address[3] memory addressArr, uint[3] memory uintArr)
```
Executes the transferFrom function of the Core contract


```js
mint(address[2] memory addressArr, uint[2] memory uintArr)
```
Executes the mint function of the Core contract. Is not a token-native function.


```js
burn(address[2] memory addressArr, uint[2] memory uintArr)
```
Executes the burn function of the Core contract. Is not a token-native function.


```js
updateTotalSupply(uint[2] memory uintArr)
```
Executes the updateTotalSupply function of the Core contract. Is not a token-native function.


```js
updateCurrentSupply(uint[2] memory uintArr)
```
Executes the updateCurrentSupply function of the Core contract. Is not a token-native function.


```js
updateJointSupply(uint[2] memory uintArr)
```
Executes the updateJointSupply function of the Core contract. Is not a token-native function.

#### Router
##### Variables
```js
address public tokenContract;
```
This is the address of an external Toekn contract. We are using this address to call the Toekn functions, making the token mutable. 


```js
address public coreContract;
```
This is the address of an external Core contract. We are using this address to confirm the contract calls where only the Core can initiate the function. 


```js
Core private core;
```
Initiated external Core contract

```js
mapping(string => address) public externalContracts;
```
This is a collection of external contracts that to communicate with the token via router.

#### Functions-token native

```js
equals(string memory a, string memory b)
```
Function used to compare two strings

```js
currentTokenContract()
```
Returns the current Token contract address

```js
currentCoreContract()
```
Returns the current Core contract address

```js
getExternalContractAddress(string memory contractName)
```
Returns the address of an external contract provided a name of a function it is associated with

```js
setNewTokenContract(address newTokenAddress)
```
Sets the new Token contract address. This is never to be used, unless the token branches off into two different tokens, for whatever reason.

```js
setNewCoreContract(address newCoreAddress)
```
Sets the new Core contract address

```js
setNewExternalContract(string memory contractName, address newContractAddress)
```
Sets or overrides the External contract address associated with the contract name

```js
callRouter(string memory route, address[2] memory addressArr, uint[2] memory uintArr)
```
Makes the call to Contract via the Router, initiated by the Token contract, accepts arrays of the length 2.

```js
_callRouter(string memory route, address[3] memory addressArr, uint[3] memory uintArr)
```
Makes the call to Contract via the Router, initiated by the Token contract, accepts arrays of the length 3.

#### Functions-non native
```js
extrenalRouterCall(string memory route, address[2] memory addressArr, uint[2] memory uintArr)
```
This is a set of router calls to Core external to the original and the basic token contract.
