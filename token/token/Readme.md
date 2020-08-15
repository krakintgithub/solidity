## Functions and their routes

### token.sol

#### Router

##### Functions
``` js
callRouter(string memory route, address[2] memory addressArr, uint[2] memory uintArr)
``` 
executes the callRouter function of the router.sol, assuming that each array has two elements. If array has no second element, it is a null or a zero.

``` js
_callRouter(string memory route, address[3] memory addressArr, uint[3] memory uintArr)
```  
executes the callRouter function of the router.sol, assuming that each array has three elements. If array has no second or third element, it is a null or a zero.

#### MainVariables

##### Variables

```js
address public coreContract;
```
This is the address of an external Core contract. We are using this address to confirm the contract calls where only the Core can initiate the function. 

```js
address public routerContract;
```
This is the address of an external Router contract. We are using this address to call the Router functions, making the token mutable. 


```js
mapping(address => uint256) internal balances;
```
This is the map which contains all the balances.

```js
mapping(address => mapping(address => uint256)) internal allowances;
```
This is the map which contains all the allowances. This is used when one account wants to allow another to do a transfer on their behalf

```js
uint256 public _totalSupply;
```
Shows the total supply of tokens, not a hard-coded number since the token is mutable.

```js
uint256 public _currentSupply;
```
Shows the current supply of circulating tokens. This number is meant to constantly change, given the proof of burn design.


```js
string private name = "Krakin't";
```
This is the name of a token, as it will appear on exchanges, etc.

```js
string private symbol = "KRK";
```
This is the ticker symbol of a token


```js
uint8 public decimals = 18;
```
Tells us how many decimals the token has





#### Token
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
