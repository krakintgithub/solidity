## Functions and their routes

### core.sol

#### Token

##### Functions

```js
balanceOf(address account)
```
Calls the Token's balanceOf function


```js
allowance(address owner, address spender)
```
Calls the Token's balanceOf function


```js
updateTotalSupply(uint newTotalSupply)
```
Calls the Token's updateTotalSupply function


```js
updateCurrentSupply(uint newCurrentSupply)
```
Calls the Token's updateCurrentSupply function


```js
updateJointSupply(uint newCurrentSupply)
```
Calls the Token's updateJointSupply function



```js
emitTransfer(address fromAddress, address toAddress, uint amount, bool affectTotalSupply)
```
Calls the Token's emitTransfer function


```js
emitApproval(address fromAddress, address toAddress, uint amount)
```
Calls the Token's emitApproval function

#### Core
##### Variables
```js
address public tokenContract
```
The address for the native Token contract


```js
address public routerContract
The address for the native Router contract
```

```js
Token private token
```
The initialized native token contract

##### Native Functions

```js
transfer(address[2] memory addressArr, uint[2] memory uintArr)
```
Makes a token transfer via _transfer function


```js
_transfer(address[2] memory addressArr, uint[2] memory uintArr)
```
Private function making a call to Token's emitTransfer function.

address[0] - from address

address[1] - to address

uintarr[0] - amount transfered

uintarr[1] - not used


```js
approve(address[2] memory addressArr, uint[2] memory uintArr)
```
Makes a token approve via _approve function


```js
_approve(address[2] memory addressArr, uint[2] memory uintArr)
```
private function making a call to Token's emitApproval function
address[0] - owner

address[1] - spender

uintarr[0] - amount transfered

uintarr[1] - not used


```js
transferFrom(address[3] memory addressArr, uint[3] memory uintArr)
```
Makes the call to _transfer and _approve functions, assuming the pre-approved balance transfer.

tmpAddresses1[0] - transfer from address

tmpAddress1[1] - transfer to address

tmpAddress2[0] - owner address

tmpAddress2[1] - spender address

uintArr[0] - amount

uintArr[1] - not used




```js
increaseAllowance(address[2] memory addressArr, uint[2] memory uintArr)
```
Makes a call to _approve function to increase the existing allowance

address[0] - owner

address[1] - spender

uintarr[0] - amount transfered

uintarr[1] - not used


```js
decreaseAllowance(address[2] memory addressArr, uint[2] memory uintArr)

Makes a call to _approve function to decrease the existing allowance

address[0] - owner

address[1] - spender

uintarr[0] - amount transfered

uintarr[1] - not used

##### Non-native Functions


