# <p align="center">Krakin't Presale Contract (in progress)</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/krakintgithub/misc/master/doodles/purchaseDoodle.png"  title="Logo" width="200px">
</p>


## <p align="center">0x....</p>

## Introduction
### General overview

This is not a simple pre-sale swap contract. There are several aspects to keep in mind while executing it.

- This contract is a KRK sale contract that allows you to purchase KRK tokens with Ethereum.
- This contract also allows you to get your Ethereum back, with a 4% fee.
- 2% of the fee goes to Krakin't and other 2% is spread to everyone who invested.
- You can earn Ethereum with this contract as well, and cover the 4% fee.
- You can also recover from the 4% loss by using the miner and selling the newly mined tokens on a market.
- You cannot exchange more KRK to Ethereum than you have previously purchased by executing this contract.
- It does not matter where the KRK is coming from, while swapping back to Ethereum, as long as you made a purchase at some point.
- The main purpose of this contract is to encourage trading and mining.
- Every time purchase is made, new KRK tokens are minted. Every time they are swapped back to Ethereum, tokens are burned.
- The contract does not allow more than 5 million tokens to be minted and in circulation at the same time.
- Price of a token increases with the amount of purchases.
- Price of a token decreases when KRK is swapped back to Ethereum.
- Arbitrage with exchanges is possible. 

### Controlled supply vs price

Since Solidity language is limited when it comes to mathematics, instead of using a single curve formula, we are using 10 linear formulas to regulate the price of a token within the frame of this contract. Each line represents a new stage and a steeper slope. There are 10 stages in total. 

To calculate the price, assume:


x = Circulating KRK tokens

f(x) = price
 
Then, apply these formulas:

stage 1:
- f(x) = 1.9998×10^-7 x + 0.0001


stage 2:
- f(x) = 4.22202×10^-7 x - 0.111011

stage 3:
- f(x) = 6.72202×10^-7 x - 0.361011

stage 4:
- f(x) = 9.57917×10^-7 x - 0.789583

stage 5:
- f(x) = 1.29125×10^-6 x - 1.45625


stage 6:
- f(x) = 1.69125×10^-6 x - 2.45625


stage 7:
- f(x) = 2.19125×10^-6 x - 3.95625

stage 8:
- f(x) = 2.85792×10^-6 x - 6.28958
 
stage 9:
- f(x) = 3.8579×10^-6 x - 10.2895

stage 10:
- f(x) = 5.8579×10^-6 x - 19.2895
 
