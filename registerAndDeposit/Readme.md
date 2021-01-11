# <p align="center">Krakin't Exchange Token Deposit and Registration, V1.0</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/krakintgithub/misc/master/doodles/Cr12CDF58-E2DD-42CB-9E91-11220CD6F27F.jpeg" width="300px" title="Logo">
</p>


## <p align="center">0x...IN PROGRESS...
</p>




### This document is currently in progres

# Introduction
This is the contract mechanism that we will use to allow people to add and remove tokens to exchange, and also to provide the necessary Ethereum gas to get the assets in and out of the exchange. Everything else that happens within the exchange will be free. The "matrix" style doodle is not much about us hacking anything, but about the usability of the solution. To non-developers and newbies, it may look like they are hacking rather than having a nice solution. The reason for this kind of solution is because our primary goal is to:

1. Have the simplest contract as possible, and therefore, the lowest safety risk

2. Have the least amount of expenses rather than using the expensive and decentralized oracles

3. Users must have as much power as possible without exposing their private keys

4. To disable any potential risk that may involve the theft using the Krakin't private keys

5. To have a fail-safe mechanism in case something bad happens, allowing users to get their money back


### Centralized and Decentralized Components Diagram
<p align="center">
  <img src="https://raw.githubusercontent.com/krakintgithub/solidity/master/registerAndDeposit/diagram1.png" title="Logo">
</p>

This diagram is a brief overview of what goes on in the background while depositing or withdrawing a token/eth.
All actions are done via backend, while Admin account is responsible for taking some of the actions commuinicating strictly with the server-side backend.
A decentralized DAPP is also necessary, while it is communicating with the backend that will be connected to API such as Etherscan.

The frequent change of the Administrator account (with hidden private keys) is also possible, while the owner of the contract would have to transfer all the assets to the new Administrator account. This can prevent the possible hacking of the files and encrypted data where the keys are stored. Therefore, it is important to allocate ETH to Administrator account only to cover the GAS expenses, and nothing else. The Administrator account can also accumulate the ETH dust, since we will charge just a bit more ETH to cover the GAS price and to make sure that everything processed without interruptions. The dust can be collected and therefore used by the Admin account to assist creating the new Admin account or cover any other GAS fees that we need for the maintenance.

#### User deposits ETH to a contract


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
