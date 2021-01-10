# <p align="center">Krakin't Exchange Token Deposit and Registration, V1.0</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/krakintgithub/misc/master/doodles/Cr12CDF58-E2DD-42CB-9E91-11220CD6F27F.jpeg" width="300px" title="Logo">
</p>


## <p align="center">0x...IN PROGRESS...
</p>




### This document is currently in progres

#Introduction
This is the contract mechanism that we will use to allow people to add and remove tokens to exchange, and also to provide the necessary Ethereum gas to get the assets in and out of an exchange. Everything else that happens within the exchange will be free of charge. The "matrix" style doodle is not much about us hacking anything, but about the usability of the solution. To non-developers and newbies, it may look like they are hacking rather than having a nice and an intuitive solution. The reason for this kind of a solution is because our main goal is to:

1. Have the simplest contract as possible, and therefore, the lowest safety risk

2. Have the least amount of expenses rather than using the expensive and decentralized oracles

3. Users must have as much power as possible without exposing their private keys

4. To disable any potential risk that may involve the theft using the Krakin't private keys

5. To have a fail-safe mechanism in case something bad happens, allowing users to get their money back






###Ignore below:
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
