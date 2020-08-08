### Initial deployment steps
1. token.sol - Remove the fake token name and a symbol used for testing
2. token.sol - Deploy the contract
3. router.sol - hardcode the token contract address, this is to be used forever
4. router.sol - Deploy the contract
5. token.sol - add the router address as new router address
6. core.sol - hardcode the token address
7. core.sol - Deploy the contract
8. core.sol - update the router address as new router address
9. router.sol - update the core address as new core address

Only the router should change when deploying the update to a code, meaning, we do steps 4,5,8
Any additional steps that are not core-related will apply (for example, additional contracts in a router)


On Ropsten...

#### TOKEN: 
0xE4F82Ed7FEcfae6629d034332A89F4830b74ed27

https://ropsten.etherscan.io/address/0xE4F82Ed7FEcfae6629d034332A89F4830b74ed27#code
