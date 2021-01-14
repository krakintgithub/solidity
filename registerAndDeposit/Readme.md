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

Although a decentralized solution, the users do not have any control over their assets once deposited to exchange. In the future, we will not rely on using the internal and securely stored wallets. Instead, we can use an external block-chain or another contract that manages a decentralized database. Furthermore, there shouldn't be any need to make the Ethereum deposits.

The frequent change of the Administrator account (with hidden private keys) is also possible, while the owner of the contract would have to transfer all the assets to the new Administrator account. This can prevent the possible hacking of the files and encrypted data where the keys are stored. Therefore, it is important to allocate ETH to Administrator account only to cover the GAS expenses.

#### Important details to note
- We only process one transaction or function execution per block (approximately 12 seconds). Otherwise, the error is thrown. This can be managed via DAPP simply by showing the wait message, until the block number increases on the blockchain. This is also a security feature.

- API calls are made in a 5 second interval.

- Nobody can steal the assets from a contract, while no human will ever know the private key of the Admin account.

- We have a pause that prevents any activity should we detect anything suspicious.

- There is no physical and actual person as an administrator, while everything is automated using the Ethereum contract.

- Not everything is open-source. We will expose the DAPP and the block-chain contracts only. We will not expose or upload the administrator wallet source code, and it will be developed without an Internet connection. In future, no developer will have an access to it.


#### The contract variables
```
address internal _owner;
address internal adminAddress;
address internal externalContract;
```
- _owner: the contract owner
- adminAddress: the address of the Administrator wallet
- externalContract: the contract that will be used instead of the Administrator wallet for an on-chain solution

```
uint internal lastBlock;
uint internal pivot;
uint internal transactionPivot;
```
- lastBlock: the last block that under which the last function was executed
- pivot: used for keeping a track of addresses and their deposits/withdrawals
- transactionPivot: used for memorizing the block numbers for all transactions that happened, speeds up the on-chain data mining

```
mapping(address => uint) internal registration;
mapping(address => string) internal registerData;
mapping(uint => address) internal pivotToAddress;
mapping(address => uint) internal addressToPivot;
mapping(uint => uint) internal transactionHistory;
```
- registration: helps the account maintenance and flagging (for example, black lists, special offers, etc).
- registerData: used to keep the strings such as token website, important info, etc.
- pivotToAddress: converts the pivot ID to wallet address
- addressToPivot: converst the wallet address to pivot ID, 0 if not registered
- transactionHistory: per transaction pivot ID, it returns the block number under which the transaction occurred.
 
```
bool internal pause;
```
- pause: pauses the executions of the main contract functions (safety)

```
Transfer internal transfer = Transfer(address(0));
```
- transfer: Transfers the token from a contract address to user's wallet. NOTE: the token must have the common transfer function, otherwise it will remain locked!
 
#### The views:
```
function getExternalContractAddress() public view virtual returns(address externalContract)
function getAdminAddress() public view virtual returns(address admin)
function getLastBlock() public view virtual returns(uint lastBlockNumber)
function getBlockNumber() public view virtual returns(uint blockNumber)
function getAccountFlag(address userAddress) public view virtual returns(uint accountFlag)
function getRegisterData(address userAddress) public view virtual returns(string memory data)
function isPauseOn() public view virtual returns(bool safetySwitch)
function getPivot() public view virtual returns(uint pivot)
function getTransactionPivot() public view virtual returns(uint pivot)
function getAddressFromPivot(uint pivot) public view virtual returns(address userAddress)
function getPivotFromAddress(address userAddress) public view virtual returns(uint pivot)
function getTransactionFromPivot(uint pivot) public view virtual returns(uint transaction)
```
All of these functions are self-explanatory and do not need any further details and explanations.
 
#### Only-owner functions: 
```
function setAdminAddress(address newAdminAddress) external onlyOwner virtual returns(bool success)
function setExternalContractAddress(address newContract) external onlyOwner virtual returns(bool success)
function setAccountFlag(address userAddress, uint flagType) external onlyOwner virtual returns(bool success)
function updateRegisterData(address userAddress, string memory data) external virtual onlyOwner returns(bool success)
function flipPauseSwitch() external onlyOwner virtual returns(bool success)
```
- setAdminAddress: In case we need to change the Admin public key or set the Admin public key within the contract
- setExternalContractAddress: In case we decide to avoid the usage of the Admin wallet address and use contracts instead
- setAccountFlag: We can flag the accounts to see which account has which setting (special offers, partnerships, blacklist,...)
- updateRegisterData: We can register the account or a contract/token adding string data such as web-page, address, owners, ...
- flipPauseSwitch: We can pause/continue the contract deposit/withdrawal. This, however, does not pause the exchange.

#### Administrator-only functions: 

```
function registerNewEthBalance(address userAddress, uint blockNumber) external virtual onlyAdmin returns(bool success)
function registerNewTokenBalance(address userAddress, uint blockNumber) external virtual onlyAdmin returns(bool success)
function withdrawTokens(address userAddress, address tokenAddress, uint amount) external virtual onlyAdmin returns(bool success)
```
- registerNewEthBalance: Once the ETH is deposited to Admin or external contract, it is then registered and used for the GAS fees
- registerNewTokenBalance: Once the token is deposited to a contract address, it is then registered and can be used within the exchange
- withdrawTokens: The backend calculates the gain/losses, while Admin or external contract sends tokens back to user's wallet

#### Other functions:
```
function registerUser(address userAddress) private returns(bool success) {
```
- registerUser: registers a new user assigning it a pivot ID


# Work-Flow and general description

Please note:

- Users do not have to register their tokens on the block-chain. The backend system detects whether it is a new or an existing token. If token is new, users will be able to write wikipedia pages and give us more details. If you are a token owner, you will be asked to prove your identity by making a micro-transfer from a token account. Other registration forms will be provided. Everything will be optional, however, token will be graded depending on the information that is provided.

- Token name collisions are possible, and a backend solution is implemented. Similar tokens will be included on the Wiki pages. This prevents any potential scams.

- Users must deposit ETH to Administrator address to cover the GAS costs. The GAS costs include: Registering deposits, Registering withdrawals, ETH withdrawal from the Administrator account. The best approach is never to deposit the ETH that you will not use, to lower the risk.

- You will be in control of your own keys as soon as we abandon the use of the Administrator wallet and use a block-chain contract instead.





