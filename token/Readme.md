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
0x1f76E9D2D609A178141C63aC3B23F250462D8927

https://ropsten.etherscan.io/address/0x1f76e9d2d609a178141c63ac3b23f250462d8927#code
