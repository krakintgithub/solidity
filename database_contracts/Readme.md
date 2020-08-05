<p align="center">
  <img src="https://raw.githubusercontent.com/krakintgithub/misc/master/logo_s1.png" width="64px" title="Logo">
</p>

# Krakin't Decentralized Database - Technical Documentation
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
Used for managing the project administrators.

#### Maps
```admins``` this map tells us whether the account is an admin (true) or not (false).

#### Variables
```runAdminConstrOnce``` public, tells us whether the constructor was initiated, and keeps it locked and safe from hacking.

#### Constructor(s)
The main constructor simply sets the contract publisher as the administrator. We are making sure the constructor is initiated only once during a deployment.

#### Modifiers
```isAdmin``` the user must be an admin when applied to a function.

#### Views
```isAdminAccount``` this view tells us whether the certain 0x account is an admin (true) or not (false).

#### Functions
```manageAdmins``` accepts the 0x account as an input and flips the admin status from true to false and/or from false to true. Only admins can run this function.


### Owned contract
Extends the Administrated, inherits variables, maps, modifiers and functions from Administrated. Mainly for allowing the owner-only executions.

#### Events
```OwnershipTransferred``` used for transferring the ownership to some other account.

#### Variables
```owner``` public, tells us the address of the owner's 0x account.
```runOwnedConstrOnce``` public, tells us whether the constructor was initiated, and keeps it locked and safe from hacking.

#### Constructor(s)
The main constructor simply sets the owner address. We are making sure the constructor is initiated only once during a deployment.

#### Modifiers
```isOwner``` the user must be an owner when applied to a function.

#### Views
```isAdminAccount``` this view tells us whether the certain 0x account is an admin (true) or not (false).

#### Functions
```transferOwnership``` Transfers the ownership from the current owner to a provided 0x address. Can be executred by the owner only. Sets the new owner as an admin, removes admin privileges of the previous ower. To keep the admin privileges of the previous owner, we must execute the ```manageAdmins``` function. 


### MainAccessControl contract
Extends the Owned, Administrated, inherits variables, maps, modifiers and functions from Administrated and Owned. This contract is used for managing the user types. If the user-type is 1, it means that it has been banned from the database access and it cannot function with regulated.sol database.


#### Variables
```getMaintenanceFlagFunction1```,```getMaintenanceFlagFunction2```,```getDataValue1```,```getDataValue2```,```insert1``` public, these are the flags that are used to either allow the public access to main contract functions or to make it an admin-only access.

#### Functions

```flipGetMaintenanceFlagFunction1```,```flipGetMaintenanceFlagFunction2```,```flipGetDataValue1```,```flipGetDataValue2```,```flipInsert1``` public, owner-only, these functions are used to decide which functions are open to public and which functions are not. This is a very strict regulation of the contract, and therefore, only the owner can execute them (hopefully, never).

```setMaintenanceFlag``` public, Admins-only. Sets the account type onto a provided 0x address. 1 blocks the user completely.


#### Views
```getMaintenanceFlag``` public, can be restricted to Admins-only. Not restricted by default. The purpose of this function is to see the maintenance status and an account type for a 0x address. Only the Admins can check the status of someone else's account.




### Schema contract
The main contract to be compiled. Extends the Administrated, Owned, and MainAccessControl. Inherits variables, maps, modifiers and functions from Administrated, Owned, and MainAccessControl. This contract is used to read or insert/replace the data onto block-chain and make it decentralized. Inserted data is of a string type, and therefore the maintenance does cost a lot to perform. All inserts should be JSON. We can apply compression with an encryption too.


#### Maps
```dataArray``` public, it maps the user address to the schema name, and schema name to data that is stored. Schema name can be any string we choose.
 
TODO: Continue ! 
 
#### Views
```getDataValue``` public, can be set to Admins-only. Is not Admins-only by default. Shows the Schema's data. Only admin accounts can look into other's schemas.


#### Functions
```insert``` public, can be set to Admins-only. Is not Admins-only by default. Updates or adds data to a schema. JSON format (can be compressed and/or encrypted) is preferred. Only admins can alter data of another 0x account.


