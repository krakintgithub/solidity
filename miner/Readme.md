# <p align="center">Krakin't Solo Miner</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/krakintgithub/misc/master/doodles/MinerDoodle_logo.jpg"  title="Logo">
</p>


## <p align="center">0xe24F992D6E34357cF67D741769eAAD7bC44E32DD</p>

## Introduction
### General overview
The miner contract is connected to a Router component/contract of the Krakin't token. It mainly uses two functions: mint and burn. The miner contract does not store any tokens and whenever the user deposits the tokens, they are burned. When tokens are withdrawn, they are minted again from the address(0). Therefore, the miner is simply keeping a track of how many tokens were deposited or withdrawn by whom and when. In the previous version of Krakin’t miner, we have mentioned a mechanism that balances impact of minting and burning tokens by using the miner. However, we have removed this mechanism and simplified the mining process. We gave some advantages to early miners, while the mining difficulty is slowly increasing with time. Furthermore, the mining difficulty does not decrease, unless we do it manually. Since it is impossible to update everyone’s tables without wasting too much Ethereum GAS, we have introduced an asynchronous mining difficulty. 

### Asynchronous mining difficulty
Asynchronous mining difficulty works by making two calculations. First, we keep a track of the global time that passed since the mining contract got deployed on the Ethereum network. We use the Ethereum block numbers instead of the time-units such as seconds. Mining one block on Ethereum takes 12-20 seconds. As soon as the miner deposits or withdraws tokens from the miner contract, we increase the mining difficulty for them by assigning them a new Ethereum block number. As long as they do not make any changes (this includes adding more tokens to a miner), their mining difficulty will remain the same. This is how the mining difficulty is asynchronous. 

### Differences between BTC, ETH, ... and the KRK mining approach
- The first main difference is that there is no hash-rate. Since we are using the time and deposited amount of KRK to determine the power, the only process we need is a chronometer. The chronometer is the Ethereum block mining, and therefore, this is how we are avoiding the use of any specialized hardware.

- We do not need to measure the mining difficulty since we are correlating it with the speed at which Ethereum blocks are mined.

- Mining pools are not necessary since the miner is a mining pool, while difficulty is regulated by the amount of an investment and burned tokens.


## Source-code
### General overview
The main parts of the source code are: SafeMath, Ownable, Token, Router and Solo Miner.  SafeMath and Ownable are the standard methods and need no explanation. Token and router are simply pointing to Krakin't Token and the Krakin't Router. Token is used to see the user's balance of tokens. Router is used to either mint or burn the tokens. This document will therefore focus mainly on the Solo Miner component.

### Variables and their meaning
All variables are private, and they are accessed by the getter or setter methods, thus following the common Object-Oriented design.

`tokenContract` - pointer to the Token contract of Krakin't token.

`routerContract` - pointer to the Router contract of a Krakin't token.

`OldVersionMiner` - pointer to the Miner v1.0.

`rewardConstant` - constant used to calculate the reward.

`difficultyConstant` - constant used to calculate difficulty.

`decreaseDifficultyConstant` - constant used to calculate difficulty.

`mintDecreaseConstant` - constant used to calculate difficulty.

`creationBlock` - the block number at which the miner got deployed

`pivot` - the last miner ID, also tells us how many miners we have in total.

`userBlocks` - the last block that was mined when a deposit was made. This is used to calculate the reward according to a passed time.

`miners` - allows us to get the miner ID knowing the miner/user address. Also, to determine if the address is a miner/user.

`addressFromId` - allows us to get the miner address knowing the miner/user ID.

`depositedTokens` - number of tokens that the user deposited (total).

`userDifficultyConstant` - user's own difficulty constant.

`userFlag` - for marking the users, also a blacklist (when necessary to apply).

`totalMinted` - tells us the overall number of tokens that were minted.

`totalBurned` - tells us the overall number of tokens that were burned by the miner.

`userTotalMinted` - tells us the overall number of tokens that were minted by the miner/user.

`userTotalBurned` - tells us the overall number of tokens that were burned by the miner/user.

`userNumOfDeposits` - total number of user deposits

`userNumOfWithdrawals` - total number of user withdrawals

 
 

### View functions (getters)
#### Contract addresses
```solidity
function getRouterContract() external view virtual returns(address routerAddress)
```
- Returns the registered router contract.

```solidity
function getTokenContract() external view virtual returns(address tokenAddress)
```
- Returns the registered token contract.

#### Global
```solidity
function getRewardConstant() external view virtual returns(uint returnConstant)
```
- Returns the reward constant.

```solidity
function getDifficultyConstant() external view returns(uint256 returnConstant)
```
- Returns the difficulty constant.


```solidity
function getDecreaseDifficultyConstant() external view returns(uint256 returnConstant)
```
- Returns the decrease difficulty constant.


```solidity
function getMintDecreaseConstant() external view returns(uint256 returnConstant)
```
- Returns the decrease difficulty constant.


```solidity
function getCreationBlock() external view returns(uint256 blockNumber)
```
- Returns the creation block number.


#### Miner/User specific
```solidity
function getPivot() external view virtual returns(uint lastPivot)
```
- Returns the last miner/user ID, or pivot.


```solidity
function getLastBlockNumber(address minerAddress) public view virtual returns(uint lastBlock)
```
- Returns the last block number.


```solidity
function getIdFromAddress(address minerAddress) external view returns(uint256 id)
```
- Returns the miner/user ID, if address is registered.


```solidity
function getAddressFromId(uint id) external view virtual returns(address minerAddress)
```
- Returns the miner/user address, provided the ID.


```solidity
function getDepositedTokens(address minerAddress) external view returns(uint256 tokens)
```
- Returns the total deposited tokens by the user.


```solidity
function getUserDifficultyConstant(address minerAddress) external view returns(uint256 returnConstant)
```
- Returns the total deposited tokens by the user.


#### Statistics

```solidity
function getUserTotalMinted(address minerAddress) external view returns(uint256 minted)
```
- Returns the total minted tokens by the user.

```solidity
function getUserTotalBurned(address minerAddress) external view returns(uint256 burned)
```
- Returns the total deposited tokens by the user.

```solidity
function getTotalMinted() external view returns(uint256 minted)
```
- Returns the total/overall minted tokens.

```solidity
function getTotalBurned() external view returns(uint256 burned)
```
- Returns the total/overall burned (or deposited) tokens.

```solidity
function getCirculatingTokens() external view returns(uint256 burned)
```
- Returns the total circulating tokens.

```solidity
function getUserNumOfDeposits(address minerAddress) external view returns(uint256 deposits)
```
- Returns the user's number of deposits.

```solidity
function getUserNumOfWithdrawals(address minerAddress) external view returns(uint256 withdrawals)
```
- Returns the user's number of withdrawals.


#### Other
```solidity
function getCurrentBlockNumber() public view returns(uint256 blockNumber)
```
- Returns the current block number.

```solidity
function showEarned(address minerAddress) public view virtual returns(uint tokensEarned)
```
- Returns the user's earned tokens.


```solidity
function showReward(address minerAddress) public view virtual returns(uint reward)
```
- Returns the user's reward tokens.


### External public functions

```solidity
function mine(uint depositAmount) external virtual returns(bool success)
```
- Deposits tokens and starts mining. Difficulty is updated.

```solidity
function getReward(uint withdrawalAmount) external virtual returns(bool success)
```
- Withdraws tokens. Difficulty is updated.



### Setters (owner only)

```solidity
function setNewTokenContract(address newTokenAddress) onlyOwner external virtual returns(bool success)
```
- Sets the (new) Token contract.

```solidity
function setNewRouterContract(address newRouterAddress) onlyOwner external virtual returns(bool success)
```
- Sets the (new) Router contract.


```solidity
function setRewardConstant(uint newConstant) onlyOwner external virtual returns(bool success)
```
- Sets the (new) reward constant.


```solidity
function setDifficultyConstant(uint newConstant) onlyOwner external virtual returns(bool success)
```
- Sets the (new) difficulty constant.


```solidity
function setDecreaseDifficultyConstant(uint newConstant) onlyOwner external virtual returns(bool success)
```
- Sets the (new) decrease difficulty constant.


```solidity
function setMintDecreaseConstant(uint newConstant) onlyOwner external virtual returns(bool success)
```
- Sets the (new) mint decrease constant.


```solidity
function setUserFlag(address minerAddress, uint flag) onlyOwner external virtual returns(bool success)
```
- Flags the address, can be used as a black-list.

### Other funcions (owner only)
```solidity
function transferSnapshot(address oldMinerAddress) onlyOwner public virtual returns(bool success) {
```
- Used only once, to transfer all users and their data from the miner v1.0 to miner v2.0

```solidity
function ownerAddTokens(address minerAddress, uint depositAmount) onlyOwner external virtual returns(bool success)
```
- Adds tokens to user miner address (to be used if numbers need to be fixed, or if there is a special promotion).

```solidity
function ownerRemoveTokens(address minerAddress, uint withdrawalAmount) onlyOwner external virtual returns(bool success)
```
- Removes tokens fraom a user address (to be used if numbers need to be fixed).


### Private functions

```solidity
function registerMiner(address minerAddress) private
```
- Registers the new miner/user address if not already registered.

```solidity
function updateDifficulty(address minerAddress) private
```
- Updates the mining difficulty per user address (used with a deposit or a withdrawal).

```solidity
function burn(uint burnAmount) private returns(bool success)
```
- Burns tokens, used when depositing.

```solidity
function mint(uint mintAmount) private returns(bool success)
```
- Mints tokens, used when withdrawing.

