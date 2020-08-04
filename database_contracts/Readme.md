<p align="center">
  <img src="https://raw.githubusercontent.com/krakintgithub/misc/master/logo_s1.png" width="64px" title="Logo">
</p>

# Krakin't Technical documentation
## Decentralized schemas

### Explanation

In order to keep data regarding the startups, individuals, ideas, and so on secure and protected on the block-chain, we need to make a contract that would enable us to add the data onto block-chain. The contract is to be called with the web3j or directly with any other interface. There are two kinds of contracts for each data-type. One ends with regulated.sol other with noadmin.sol. Regulated means that the contract can be adjusted by the project owner or the system administrators. Noadmin means that only the contract owner can add/edit their own data and do nothing else.

Currently, keeping the string schemas has been declared as experimental by using the "pragma experimental ABIEncoderV2;" rather than complicating the code by (De)serializing the string or bytes32 arrays. This may change in the future should the test-cases fail or should there be a security issue.

Our design will not use any other contract to read/write data using this schema, while the web3j will become an interface that will communicate between the contracts. 

