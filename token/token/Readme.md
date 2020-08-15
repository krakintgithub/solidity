##### Functions-views

```js
totalSupply()

```
Returns the totalSupply()

```js
currentSupply()
```
Returns the current supply

```js
balanceOf(address account)
```
Returns the balance of an account

```js
allowance(address owner, address spender)
```
Returns the allowance between owner and spender (how much is spender allowed to transfer from the owner)

```js
currentRouterContract()
```
Returns the address of the current Router contract

```js
currentCoreContract()
```
Returns the address of the current Core contract

##### Functions-updates


```js
updateTicker(string memory newSymbol)
```
If owner decides to change the ticker symbol (rebranding), however, it is meant never to be used

```js
updateName(string memory newName)
```
If owner decides to change the token name (rebranding), however, it is meant never to be used


```js
updateAllowance(address owner, address spender, uint newAllowance)
```
Is to be used by the anyone who wants to increase/decrease the allowance for a spender account knowing the exact new amount

##### Functions-emits

```js
emitTransfer(address fromAddress, address toAddress, uint amount)
```
Used by the Core only, is meant to transfer any amount of tokens to any address is allowed to burn and mint tokens too.

```js
emitApproval(address fromAddress, address toAddress, uint amount)
```
Used by the Core only, is meant to approve the token transfers from fromAddress to toAddress

##### Functions-router and core
```js
setNewRouterContract(address newRouterAddress)
```


```js
setNewCoreContract(address newCoreAddress)
```



##### Functions-core


```js
transfer(address toAddress, uint256 amount)
```


```js
approve(address spender, uint256 amount)
```


```js
transferFrom(address fromAddress, address toAddress, uint256 amount)
```


```js
increaseAllowance(address spender, uint256 addedValue)
```


```js
decreaseAllowance(address spender, uint256 subtractedValue)
```
