# <p align="center">Krakin't Solo Miner</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/krakintgithub/misc/master/doodles/MinerDoodle_logo.jpg"  title="Logo">
</p>


## <p align="center">0xE91c47806D720a8C0A8A87473E6788d30EB1D8F0</p>
new: 0x9A6606385A097c65791b2b81Fb6FC367c0A75FF9

## Introduction
### General overview
The miner contract is connected to a Router component/contract of the Krakin't token. It mainly uses two functions: mint and burn. The miner contract does not store any tokens and whenever the user deposits the tokens, they are burned. When tokens are withdrawn, they are minted again from the address(0). Therefore, the miner is simply keeping a track of how many tokens were deposited or withdrawn by whom and when. To apply the proof of a burn, we are simply keeping a ratio of the total supply in comparison to the current supply as well as the number of tokens that were burned, per user. Since we want the Krakin't token supplies to be loosely related to the actual token supplies, we have initiated the miner with the assumed total and a current supply. For example, if an exchange needs more tokens to be minted and deposited for liquidity, then it should not have any impact on the miner and the reward amounts. For this reason, we cannot directly relate to the actual token supply. Nevertheless, whenever the tokens are minted or burned by the miner, those tokens are included within the actual supply. Simply, all the ratio is related to an initial assumption regarding the supply, while the minting and burning are related to the actual token supply.

### Differences between BTC, ETH, ... and the KRK mining approach
- The first main difference is the fact that there is no hash-rate. Since we are using the time and deposited amount of KRK to determine the power, the only process we need is a chronometer. The chronometer is the Ethereum block mining, and therefore, this is how we are avoiding the use of any specialized hardware.

- We do not need to measure the mining difficulty since we are correlating it with the speed at which Ethereum blocks are mined.

- We are not using any halving and the rewards per block are a constant in relation to deposited tokens. Halving is removed in order to avoid the unfair early advantages.

- Every time tokens are burned by the miner, the mining rewards increase according to an assumed total versus current supply ratio.

- The supply of tokens increases by demand and not the time, whenever the tokens are minted with the miner.

- Mining pools are not necessary since the miner is a mining pool, while difficulty is regulated by the amount of an investment and burned tokens.

## Source-code
### General overview
The main parts of the source code are: SafeMath, Ownable, Token, Router and Solo Miner.  SafeMath and Ownable are the standard methods and need no explanation. Token and router are simply pointing to Krakin't Token and the Krakin't Router. Token is used to see the user's balance of tokens. Router is used to either mint or burn the tokens. This document will therefore focus mainly on the Solo Miner component.

### Variables and their meaning
All variables are private, and they are accessed by the getter or setter methods, thus following the common Object-Oriented design.

`tokenContract` - pointer to the Token contract of Krakin't token.

`routerContract` - pointer to the Router contract of a Krakin't token.

`totalBurned` - tells us the overall number of tokens that were burned by the miner.

`totalMinted` - tells us the overall number of tokens that were minted by the miner.

`active` - the miner off/on switch, in case we decide to stop/continue the miner contract.

`numerator` - used for calculating user's rewards, since Solidity does not allow decimals.

`denominator` - used for calculating user's rewards, since Solidity does not allow decimals.

`minimumReturn` - this is the number of tokens (deposited amount) that user will get back regardless even if the miner is stopped.

`userBlocks` - the last block that was mined when a deposit was made. This is used to calculate the reward according to a passed time.

`miners` - allows us to get the miner ID knowing the miner address. Also, to determine if the address is a miner.

`addressFromId` - returns the address of a miner providing an incremental ID. We can use this to see the current status of a miner.

`mutex` - safety protocol to avoid the contract attacks by overflowing it.

`pivot` - the last miner ID, also tells us how many miners we have in total.

`rewardConstant` - a constant used to determine how much the users are earning by block. Changing this value would change everyone's rewards. This is why it is important not to change it, unless necessary.

`totalConstant` - assumed total supply of Krakin't tokens.

`currentConstant` - assumed current supply of Krakin't tokens.

`inflationBuffer` - we use this buffer to regulate the point at which the minting the new tokens will affect the rewards of a collective. Otherwise, if this number is not reached, we continue introducing new tokens by the means of inflation. We may alter this variable as necessary. Initially, we allow 10 million tokens to be introduced.

`contractAddress` - the address of a miner contract.

### View functions (getters)

```solidity
function getLastPivot() external view virtual returns (uint lastPivot)
```
- Returns the pivot variable as well as the amount of miners.

##
```solidity
function getAddressFromId(uint id) external view virtual returns(address minerAddress)
```
- Returns the miner address provided an ID (pivot).

```solidity
function getUserNumerator(address minerAddress) external view virtual returns(uint minerNumerator)
```
- To calculate the user reward as well as a deposit.

##

```solidity
function getUserDenominator(address minerAddress) external view virtual returns(uint minerDenominator)
```
- To calculate the user reward as well as a deposit.

##

```solidity
function getUserBlocks(address minerAddress) external view virtual returns(uint minerBlocks)
```
- To get the last block of the last deposit by the user.

##

```solidity
function getContractAddress() external view virtual returns(address tokenAddress)
```
- Returns THIS contract address.

##

```solidity
function getTokenContract() external view virtual returns(address tokenAddress)
```
- Returns the Krakin't Token contract the miner is pointing to.

##

```solidity
function getTotalBurned() external view virtual returns(uint burned)
```
- Returns the total number of burned tokens (by the miner).

##

```solidity
function getTotalMinted() external view virtual returns(uint burned)
```
- Returns the total number of minted tokens (by the miner).

##

```solidity
function getLastBlockNumber(address minerAddress) public view virtual returns(uint lastBlock)
```
- Returns last transaction block number for the miner.

##

```solidity
function getRouterContract() external view virtual returns(address routerAddress)
```
- Returns the Krakin't Router contract the miner is pointing to.

##

```solidity
function getCurrentBlockNumber() public view returns(uint256 blockNumber)
```
- Returns the latest Ethereum block number.

##

```solidity
function getGapSize() public view virtual returns(uint gapSize)
```
- Returns a difference between the assumed total and current supplies, for calculating the rewards.

##

```solidity
function getRewardConstant() external view virtual returns(uint routerAddress)
```
- Returns the reward constant used to determine how much the users are earning per block.

##

```solidity
function getTotalConstant() external view virtual returns(uint totalConstant)
```
- Returns the assumed total supply.

##
```solidity
function getCurrentConstant() external view virtual returns(uint currentConstant)
```
- Returns the assumed current supply.

##
```solidity
function getinflationBuffer() external view virtual returns(uint inflationBuffer)
```
- Returns the inflationBuffer constant.

### View functions (other)

```solidity
function showReward(address minerAddress) public view virtual returns(uint reward)
```
- Returns the current user reward.


### External public functions

##
```solidity
  function mine(uint depositAmount) isActive external virtual returns(bool success) 
```
- Deposits, updates the maps, and burns the deposited tokens for mining. Increases everyone's reward by burning and widening the gap.

##
```solidity  
function getReward(uint tokenAmount) isActive public virtual returns(bool success) 
```
- Gets a reward back from the miner contract by a specified amount.

##
```solidity
function getFullReward() isActive public virtual returns(bool success) 
```
- Gets the full reward from the miner contract.

##
```solidity
function recoverOnly() external virtual returns(bool success) 
```
- Allows the token recovery when the miner is stopped.

##
```solidity
function burnMyTokens(uint tokenAmount) isActive public virtual returns(bool success)
```
- Burns the specified amount of tokens without depositing them. Increases everyone's reward. Mainly used by the project owner to increase everyone's rewards.


### Setters (owner only)

##
```solidity
function setNewTokenContract(address newTokenAddress) onlyOwner public virtual returns(bool success)
```
- Re-route for the Token contract.

##
```solidity
function setNewRouterContract(address newRouterAddress) onlyOwner public virtual returns(bool success) 
```
- Re-route for the Router contract.

##
```solidity
function setRewardConstant(uint newConstant) onlyOwner public virtual returns(bool success) 
```
- Changes the reward constant, should not be touched unless necessary.

##
```solidity
function setInflationBuffer(uint newConstant) onlyOwner public virtual returns(bool success) 
```
- Changes the inflation buffer, allowing less or more inflation.

##
```solidity
function setCurrentConstant(uint newConstant) onlyOwner public virtual returns(bool success)
```
- Changes the assumed current supply.

##
```solidity
function setTotalConstant(uint newConstant) onlyOwner public virtual returns(bool success) 
```
- Changes the assumed total supply.

### Other funcions (owner only)

##
```solidity
function flipSwitch() external onlyOwner returns(bool success)
```
- Sets the active miner to inactive, and inactive to active (on/off switch).


### Private functions

##
```solidity
function registerMiner() private 
```
- Registers a new miner address with a contract.

##
```solidity
function showMyCurrentRewardTotal() private view returns(uint reward)
```
- returns the current reward total, used while calculating a reward.

##
```solidity
function burn(uint burnAmount) isActive private returns(bool success) 
```
- Burns the tokens.

##
```solidity
function mint(uint mintAmount) isActive private returns(bool success) 
```
- Mints new tokens.

