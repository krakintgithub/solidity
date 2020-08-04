<p align="center">
  <img src="https://raw.githubusercontent.com/krakintgithub/misc/master/logo_s1.png" width="64px" title="Logo">
</p>

# Krakin't Technical Documentation
## Decentralized schemas

### Explanation

In order to keep data regarding the startups, individuals, ideas, and so on secure and protected on the block-chain, we need to make a contract that would enable us to add the data onto block-chain. The contract is to be called with any interface. There are two kinds of contracts for each data-type. One is regulated.sol other is noadmin.sol. Regulated means that the contract can be adjusted by the project owner or the system administrators. Noadmin means that only the contract owner can add/edit their own data and do nothing else.

Currently, we need to keep everything as the string type (JSON format) since Ethereum does not support multi-dimensional arrays. Furthermore, we can always compress the JSON to make it less expensive. This means that we should keep only the static data on the Ethereum's network. The more dynamic data should be kept elsewhere (centralized or a different technology, other block-chains, etc). Multi-array support is the work in progress while in the meantime we may not need to implement it.

## Code overview for noadmin contract

### Maps
```dataArray``` Location where all data is stored. Address is the user address followed by the string (which is the name of the schema) followed by the data of a string format. The string (schema) can be any string, indicating that we can have multiple schemas per user's address. 

### Functions
```getDataValue``` is a function which returns the data specifying the schema name as the key.

```insert``` is a function which allows us to either add a new or replace the old data in the table. Only the user can write onto their own tables. Preferred format is JSON, compressed.
