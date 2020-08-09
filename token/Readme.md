<p align="center">
  <img src="https://raw.githubusercontent.com/krakintgithub/misc/master/logo_s1.png" width="64px" title="Logo">
</p>

# Krakin't [KRK] Version 0.01 - Technical Documentation

## Introduction to design

The basic mutable design consists of three files: Token, Router, and a Core. We are using the adjusted proxy design pattern while trying to mimic the MVC model. The token.sol is the part that will never change once deployed. However, router.sol and core.sol can change if and only if we find it necessary. Token consists of all the functions that one simple and a basic token should have in order to be integrated into exchanges, software components, wallets, etc. Router is simply a middle-man contract which enables us to communicate with any other contract (for example, miner contract, treasury, data-base, etc). Core is a contract where all the token functions happen, which is analogous to the Controller part of the MVC model. Core communicates only with the services provided in the Token contract. The user can access any views of any of the contracts, while any additional interaction (other than executing the basic Token functions) is to be done through other contracts that are mapped with the Router contract. As analogy to a MVC design:

Model: token.sol

View: partially token.sol and any other contract we may add

Controller: partially core.sol and any other contract we may add

Database: regulated.sol and noadmin.sol

Service: external application or any other contract we may add to communicate with a database

Router: router.sol




This design is great for a simple use, however, there is a high danger of things becoming too complicated. In order to avoid creating complications, any additional design should, under almost any circumstance, remain the same as in a diagram below. If not, then we are either not doing things properly, or the project is introducting something innovative. Furthermore, any change must be clearly documented so the track of connected contracts is not lost.


</br>
<p align="center">
  <img src="https://raw.githubusercontent.com/krakintgithub/misc/master/diagrams/Untitled%20Diagram_2.jpg"  title="Basic Diagram">
</p>


## Deployment

1. token.sol [contract: Token], router.sol [contract: Router], and core.sol [contract: Core] are to be deployed (and code verified). 
2. token.sol must update the router and core addresses from address(0)
3. router.sol must update the token and the core addresses from address(0)
4. core.sol must update the token and the router addresses from address(0)
5. any other additional contract pointing to a router must be added to a router using setNewExternalContract

-work is in progress, please come back in a week or so. Thanks!
