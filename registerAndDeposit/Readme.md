# <p align="center">Krakin't Exchange Token Deposit and Registration, V1.0</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/krakintgithub/misc/master/doodles/Cr12CDF58-E2DD-42CB-9E91-11220CD6F27F.jpeg" width="300px" title="Logo">
</p>


## <p align="center">0x...IN PROGRESS...
</p>




### This document is currently in progres

# Introduction
This is the contract mechanism that we will use to allow people to add and remove tokens to (and from an) exchange, and also to provide the necessary Ethereum gas to get the assets from the exchange. The main goal is to create an exchange where liquidity deposits are not a requirement. However, the main requirement is to provide the gas to a contract (or a wallet) that registers deposits and makes withdrawals.

Since having an on-chain database is too expensive, we are falling back to centralized solutions that cost less and are scalable. As block-chain is already tracking deposits and withdrawals, we do not track what is already done for us. However, we register each block when some action happenes. As we only allow one action per block, it becomes very easy to track how many tokens were deposited-to and withdrawn-from an exchange contract. This way, we can always replicate  data and replicate the exchange mechanism on any decentralized platform. Nevertheless, unless we run our own block-chain, we cannot replicate the inner state of an exchange and users' earnings/losses. This would require either a live block-chain update or a snapshot mechanism. At the moment of writing this document, we will start with the centralized database and the centralized live updates as well as the snapshot backups that will be kept offline.

Our primary goal is to:

1. Have the simplest contract as possible, and therefore, the lowest safety risk

2. Have the least amount of expenses rather than using the expensive and decentralized oracles

3. Have an exchange where liquidity deposits are not necessary

4. Users must have as much power as possible without exposing their private keys

5. To have a solution that is modular and that will become decentralized (similar to Krakin't token architecture)


### Centralized and Decentralized Components Diagram
<p align="center">
  <img src="https://raw.githubusercontent.com/krakintgithub/solidity/master/registerAndDeposit/diagram1.png" title="Logo">
</p>

Currently, although a decentralized solution, the users do not have any control over their assets once deposited to exchange. In the future, we will not rely on using the internal and securely stored wallets. Instead, we can use an external block-chain or another contract that manages a decentralized database. Furthermore, there shouldn't be any need to make the Ethereum deposits.

The frequent change of the Administrator account (with hidden private keys) is also possible, while the owner of the contract would have to transfer all the assets to the new Administrator account. This can prevent the possible hacking of the files and encrypted data where the keys are stored. Therefore, it is important to allocate ETH to Administrator account only to cover the GAS expenses.

#### Important details to note
- We only process one transaction or function execution per block (approximately 12 seconds). Otherwise, the error is thrown. This can be managed via DAPP simply by showing the wait message, until the block number increases on the blockchain. This is also a security feature.

- Nobody can steal the assets from a contract, while no human will ever know the private key of the Admin account.

- We have a pause that prevents any activity should we detect anything suspicious.

- There is no physical and actual person as an administrator, while everything is automated using the Ethereum contract, web3j and a Java version of the web3.


##### The list of views:
```
function getEthBalance(address userAddress) public view virtual returns(uint ethAmount)
function getAdminAddress() public view virtual returns(address admin)
function getOwnerAddress() public view virtual returns(address admin)
function getNextContractAddress() public view virtual returns(address admin)
function getLastBlock() public view virtual returns(uint lastBlockNumber)
function getContractEth() public view virtual returns(uint contractEth)
function getAssetBalace(address userAddress, address tokenAddress) public view virtual returns(uint assetAmount)
function getAccountFlag(address userAddress) public view virtual returns(uint accountFlag)
function isTokenBlacklisted(address tokenAddress) public view virtual returns(bool onBlacklist)
function getPivot() public view virtual returns(uint pivotNum)
function getEthDust() public view virtual returns(uint dustEth)
function isSafetyOn() public view virtual returns(bool safetySwitch)
function isPauseOn() public view virtual returns(bool safetySwitch)
```

##### The list of users' decentralized function calls:
```
function depositEth() external payable notPaused
function withdrawEth(uint amount) external virtual notPaused returns(bool success)
function sendEthToAdmin(uint amount) external virtual notPaused returns(bool success)
function transferFromUser(address tokenAddress, uint amount) external virtual notPaused returns(bool success)
```

##### The list of users' centralized function calls:
```
function withdrawAssets(address userAddress, address tokenAddress, uint amount) external virtual notPaused returns(bool success)
```

##### The list of administrator and/or owner-only function calls:
```
function setAdminEth(address userAddress, uint amount) external virtual notPaused returns(bool success)
function setAccountFlag(address userAddress, uint flagType) external virtual notPaused returns(bool success)
function tokenBlacklistSwitch(address tokenAddress) external virtual notPaused returns(bool success)
function collectDust() external virtual notPaused returns(bool success)
function updateRegisterData(address userAddress, string memory data) external virtual onlyOwner notPaused returns(bool success)
```

##### The list of owner-only function calls:
```
function setNextContractAddress(address newAddress) external onlyOwner notPaused virtual returns(bool success)
function setAdminAddress(address newAdminAddress) external onlyOwner notPaused virtual returns(bool success)
function flipSafetySwitch() external onlyOwner virtual notPaused returns(bool success)
function flipPauseSwitch() external onlyOwner virtual returns(bool success)
```

##### The list of emergency-only function calls:
```
function emergencyWithdrawEth() external virtual notPaused returns(bool success)
function emergencyWithdrawAssets(address tokenAddress) external virtual notPaused returns(bool success)
````


#### User deposits ETH to a contract

Dapp takes care of the contract interaction, while it collects the Ethereum transaction ID to send it to a backend server and store it in a database. Once everything is processed, user can continue using the Dapp for depositing the assets, while everything is updated via the API call to Etherscan to read the blockchain data and the state of a transfer. In the meantime, while waiting for transaction to complete, users can trade with their previously deposited assets and earnings. They won't be able to deposit or withdraw from the contract. It is important not to select the cheapest transfer as an option, since DAPP may appear frozen until transaction is finally completed or rejected.

```
mapping(address => uint) private depositedEth;
```
This map is used to keep a track of how much ETH has been deposited to a contract. This ETH can be used for trading or for forwarding it to the Admin account. DO NOT send any ETH directly to the Admin account, since we must register all the ETH deposits.

```
function depositEth() external payable {
```
The payable function where user can input the amount of ETH they wish to transfer to a contract. This ETH can stay for exchange or be transferred to the Administrator to pay for the GAS fees.

#### User sends ETH to administrator account

DAPP is used to send ETH to a contract. Please do not send any ETH directly to a contract address, it will be complicated to process or retrieve it. 

```
mapping(address => uint) private adminEth;
```
This map is used to track how much Eth was sent to Administrator account to cover the GAS fees.

```
function sendEthToAdmin(uint amount) public virtual returns (bool success){
```
This function is executed using a DAPP, while it also updates the adminEth map.




### Ignore below:
- Step 1: user deposits a token DONE!
- Step 2: user registers a token using DAPP

-------------

- Step 3: user asks for withdrawal
- Step 4: user withdraws

Owner account does: 3, needs deposited ETH


TODO:

Contract-Side

1. Eth deposit for withdrawal processing
2. Registration providing a block number, add encrypted message
3. Withdrawal approval
4. Withdrawal of tokens and/or deposited ETH
5. Blacklist of tokens and wallets
6. Admin list, add or remove
7. GAS calculation before execution
8. Prevent owner/admin from stealing tokens or ETH

Backend-side
1. API call to blockchain to get deposit data providing a block number
2. Encryption/Decryption/Confirmation
3. Allowing of withdrawals by admin or owner
4. General DB management
5. Safe storage of private keys (Encryption and admin wallet)
