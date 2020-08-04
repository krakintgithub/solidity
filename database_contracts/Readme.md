<p align="center">
  <img src="https://raw.githubusercontent.com/krakintgithub/misc/master/logo_s1.png" width="64px" title="Logo">
</p>

# Krakin't decentralized Database Technical Documentation
## Decentralized schemas

### Explanation

In order to keep data regarding the startups, individuals, ideas, ... secure and protected on the block-chain, we need to make a contract that would enable us to add the data onto block-chain. The contract can be called by any interface. There are two kinds of contracts for each data-type. One is regulated.sol other is noadmin.sol. Regulated means that the contract can be adjusted by the project owner or the system administrators. Noadmin means that only the contract owner can add/edit their own data and do nothing else.

Currently, we need to keep everything as the string type (JSON format) since Ethereum does not support multi-dimensional arrays. Furthermore, we can always compress the JSON to make it less expensive. This means that we should keep only the static data on the Ethereum's network. The more dynamic data should be kept elsewhere (centralized or a different technology, other block-chains, etc). Multi-array support is the work in progress while in the meantime we may not need to implement it.

## Code overview for noadmin.sol schemas

### Maps
```dataArray``` Location where all data is stored. Address is the user address followed by the string (which is the name of the schema) followed by the data of a string format. The string (schema) can be any string, indicating that we can have multiple schemas per user's address. 

### Functions
```getDataValue``` is a function which returns the data specifying the schema name as the key.

```insert``` is a function which allows us to either add a new or replace the old data in the table. Only the user can write onto their own tables. Preferred format is JSON, compressed.

## Code overview for regulated.sol schemas

### Contracts
```Administrated``` This contract is used to allow the administrators to access any of the functions that may be otherwise restricted to anyone else. Furthermore, it contains the flags which tell us whether an account is an administrator or not.

```Owned``` extends Administrated. The standard Owned contract, adjusted to make the (new) owner the administrator.

```Maintained``` extends Owned. This contract is used to keep the track of the accounts, for example, the account with the value 1 has all access restricted and cannot view or alter the data associated with their account. Any other number is to be used with the external applications.

```MainAccessControl``` extends Maintained. We can regulate whether the contract is admin-only or not by flipping the flags.

```Schema``` extends MainAccessControl. The main contract used for storing the data on the Ethereum network.

### Administrated contract

#### Maps
```admins``` this map tells us whether the account is an admin (true) or not (false).

#### Constructor(s)
The main constructor simply sets the contract publisher as the administrator. We are making sure the constructor is initiated only once during a deployment.

#### Modifiers
```isAdmin``` the user must be an admin when used with a function

#### Views
```isAdminAccount``` this view tells us whether the certain 0x account is an admin (true) or not (false)

#### Functions
```manageAdmins``` accepts the 0x account as an input and flips the admin status from true to false and/or from false to true


