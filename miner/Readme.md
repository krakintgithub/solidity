# Krakin't Solo Miner
## 0xE91c47806D720a8C0A8A87473E6788d30EB1D8F0

### General overview
Miner contract is connected to a Router component/contract of the Krakin't token. It mainly uses two functions: mint and burn. The miner contract does not store any tokens and whenever the user deposits the tokens, they are burned. When tokens are withdrawn, they are minted again from the address(0). Therefore, the miner is simply keeping a track of how many tokens were deposited or withdrawn by whom and when. To apply the proof of a burn, we are simply keeping a ratio of the total supply in comparison to the current supply as well as the amount of tokens that were burned, per user. Since we want the Krakin't token supplies to be loosely related to the actual token supplies, we have initiated the miner with the assumed total and a current supply. For example, if an exchange needs more tokens to be minted and deposited for a liquidity, then it should not have any impact on the miner and the reward amounts. For this reason, we cannot directly relate to the actual token supply. Nevertheless whenever the tokens are minted or burned by the miner, those tokens are included within the actual supply. Simply, all the ratio is related to an initial assumption regarding the supply, while the minting and burning is related to the actual token supply.

### Difference between BTC, ETH, ... and the KRK mining approach
The KRK miner is simply piggy-backing
