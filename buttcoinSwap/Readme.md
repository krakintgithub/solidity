ROPSTEN:

butt: 0x38b810BD9Bef140F3039AC78D68337705aF09259

token: 	0xf61cc2A22D2Ee34e2eF7802EdCc5268cfB1c4A71

router: 	0xfaA85A16cE2c0CD089e0Dc1c44A7A39e6AB4dE7F

core: 		0x4ca92f46fEbc3A9a456B22E291F04B13b8c0A164

==================================================================

swap:		0xb00a3B51A166e03356D1B354a124Ae622cF75cb4


#### Testing Sequence
- Deploy the swap with addresses hardcoded - https://ropsten.etherscan.io/tx/0x30bfa391f371cbb649e66673cba2ba52e1f58aec72ef4bbc793f0a7addc60adb - OK
- Approve Buttocoins on a Buttcoin contract - https://ropsten.etherscan.io/tx/0x7d21312d134444efa5d4aaead1c7fd82ef37646131c0ba24ff26e2cafbc057a9 - OK
- Inspect all public variables - OK
- Send some KRKs to a contract - https://ropsten.etherscan.io/tx/0xd7e1bb195d29ef1268e14c68f63e2aee34956f5bc9fdc2c97d77c0a4f680742b - OK
- Swap 10,000.00000000 butts - https://ropsten.etherscan.io/tx/0x2e983aa79be7bf03a226aeff131317c46bb006ea8d7d7d4083a5cfb0416aa31b - OK
- Over the limit should not work - OK
- Should not work with KRK amounts too high - OK
- Switch to account with 0 butts, try the swap and other functions, should not work - OK
- Stop the contract - OK
- Switch to account with 0 butts, nothing should work - OK
- Switch back, recover buttcoin - https://ropsten.etherscan.io/tx/0xa458996227dd49c6ba541f5e17c0662b2ad519b42dff41f13b915032b8fc5bef -OK
- Recover again, nothing happens - OK
- Burn the remaining KRKs with the owner address - OK
