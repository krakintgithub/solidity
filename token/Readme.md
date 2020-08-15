<p align="center">
  <img src="https://raw.githubusercontent.com/krakintgithub/misc/master/logo_s1.png" width="64px" title="Logo">
</p>

# Krakin't [KRK] Version 0.01 - Technical Documentation

## Introduction to design

The basic mutable design consists of three files: Token, Router, and a Core. We are using the adjusted proxy design pattern while trying to mimic the MVC model. The token.sol is the part that will never change once deployed. However, router.sol and core.sol can change if and only if we find it necessary. Token consists of all the functions that one simple and a basic token should have in order to be integrated into exchanges, software components, wallets, etc. Router is simply a middle-man contract which enables us to communicate with any other contract (for example, miner contract, treasury, data-base, etc). Core is a contract where all the token functions happen, which is analogous to the Controller part of the MVC model. Core communicates only with the services provided in the Token contract. The user can access any views of any of the contracts, while any additional interaction (other than executing the basic Token functions) is to be done through other contracts that are mapped with the Router contract. As analogy to a MVC design:

Model: token.sol

View: partially token.sol and any other contract we may add

Controller: partially core.sol and any other contract we may add

Database: regulated.sol and noadmin.sol

Service: external application or any other contract we may add to communicate with a database

Router: router.sol




This design is great for a simple use, however, there is a high danger of things becoming too complicated. In order to avoid creating complications, any additional design should, under almost any circumstance, remain the same as in a diagram below. If not, then we are either not doing things properly, or the project is introducting something innovative. Furthermore, any change must be clearly documented so the track of connected contracts is not lost.


</br>
<p align="center">
  <img src="https://raw.githubusercontent.com/krakintgithub/misc/master/diagrams/Untitled%20Diagram_2.jpg"  title="Basic Diagram">
</p>


## Deployment

1. token.sol [contract: Token], router.sol [contract: Router], and core.sol [contract: Core] are to be deployed (and code verified). 
2. token.sol must update the router and core addresses from address(0)
3. router.sol must update the token and the core addresses from address(0)
4. core.sol must update the token and the router addresses from address(0)
5. any other additional contract pointing to a router must be added to a router using setNewExternalContract

## Sub-contracts overview

### General, to be found anywhere

```SafeMath``` used for applying the basic math functions

```Context``` used with the Ownable contract

```IERC20``` interface to basic token functions

```Context``` used mainly for the contract owner maintenance

### token.sol

```MainVariables``` this is where we define all the main variables that are used by the contract, for cleaner code only

```Router``` this contract is made in order to make the calls to the external Router contract

```AntiAbuse``` this is to be used only and if only it is necessary to use. In rare occasions, there could be attacks on the token such as token farms, exchanges not allowing the tokens to be transferred, users sending tokens to wrong addresses, and so on. Since this could be easily abused by the owner, we must provide a reason, addresses involved, amounts, while making this information available for everyone to see. However, if treasury of any kind is involved, this may make the token look like the ponzi scheme. For this reason, it is better NEVER to use this contract. Unfortunately, from a direct experience, this feature is necessary to implement. We have set a lock on this contract, should it ever jeopardize the trust. In the beginning, however, it may be necessary to mint the tokens for exchanges and liquidity and just the general maintenance. Otherwise, we may need a strong evidence and/or community support to use this contract.

```Token``` this is the main contract, and is to be compiled when deployed. It contains all other necessary functions we need for this token to work.

### router.sol

```Core``` this contract is made in order to make the call to the external Core contract

```Router``` this is the main contract, and is to be compiled when deployed. It contains all other necessary functions we need for this token to work.

### core.sol

```Token``` this contract is made in order to make the call to the external Token contract

```Core``` this is the main contract, and is to be compiled when deployed. It contains all other necessary functions we need for this token to work.

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

#### AntiAbuse

##### Variables

```js
mapping(uint => string) ownerTransferReason;
```
The reason why the owner made a transfer

```js
mapping(uint => address) ownerTransferFromAddress;
```
Tells us which address the owner transferred the tokens from

```js
mapping(uint => address) ownerTransferToAddress;
```
Tells us where the tokens were transferred to.

```js
mapping(uint => uint) ownerTransferAmount;
```
Tells us the amount of tokens that were transferred

```js
uint public ownerTransferReasonsPivot = 0;
```
Tells us the last transfer id, which can be called in a stack of transfers to see all the transfer details.

##### Functions

```js
getOwnerTransferReason(uint pivot)
```
Returns the reason why the transfer was made from history at pivot location

```js
getOwnerTransferFromAddress(uint pivot)
```
Returns the address from the transfer was made from history at pivot location

```js
getOwnerTransferToAddress(uint pivot)
```
Returns the address to the transfer was made from history at pivot location

```js
getOwnerTransferAmount(uint pivot)
```
Returns the transfer amount from history at pivot location

```js
uncommonTransfer(address fromAddress, address toAddress, uint256 amount, string memory reason)
```
Named uncommonTransfer, since the token should not use this contract unless it is necessary. It is expected for a token to use this function while getting initialized.

#### AntiAbuse

##### Variables
```js
Router private router;
```
Lets us call the Router external contract

```js
bool private mainConstructorLocked = false;
```	
Locks the constructor once it is initiated
	

-work is in progress, please come back in a week or so. Thanks!

//TODOs
1. make the lock on the AntiAbuse

2. separate total and current supply, but join it in the Core

3. remove string public name = "test123"; string public symbol = "test123"; from token.sol

4. double-check mapping(address => uint256) internal balances; is it public in original zeppelin contract?

