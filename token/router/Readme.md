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
