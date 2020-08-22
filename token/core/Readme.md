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
