<template>
  <div class="container">

    <div class="header">
      <img src="img/cave_header.svg" width="100%">
    </div>

    <div class="b-row moveUp leftPadding">
      <div>
        <div class="logo_text">
          <h1>
            <img src="img/logo_text.png" width="25%">
          </h1>
        </div>
        <hr>
        <hr>
        <hr>
        <div class="krakintext">
          <div class="welcome">Welcome to Krakin't miner !</div>
          This simple interface will let you mine the Krakin't tokens by making an initial deposit.
          Mechanism is very similar to staking, however, we have also added <i>Proof Of Burn</i> to improve the price vs demand precision.
          Please use and install <a href="https://metamask.io/download.html" target="_blank">Metamask</a>.
          Once Krakin't tokens are deposited, simply sit back and watch your earnings grow every 20 seconds or less in a Miner Console.
        </div>

        <div class="console">

          <table style="width:100%">
            <tr>
              <th>
                <div style="opacity: 0">....................</div>
              </th>
              <th></th>
            </tr>
            <tr>
              <td>
                <div style="opacity: 0">....................</div>
              </td>
              <td>
                MINER CONSOLE<br><br>
                <div style="color: #008b00; display: inline-block;">Your Balance:</div>
                {{ reward }}<br><br>
                <div style="color: #008b00; display: inline-block;">Block Number:</div>
                {{ blockNumber }} <br><br>
              </td>
            </tr>
          </table>

          <img src="img/console.png" style='height: 100%; width: 100%; object-fit: contain'>
        </div>

          <div class="krakintext2">
            To start mining or increase the mining power, specify Krakin't token amount in a "Deposit KRK" field, and press a "Deposit" button.
            Do all confirmations in the Metamask popup-window, and wait for the network to approve your transfer. Then simply watch the Miner Console.
            Repeat the same if you want to obtain a certain amount of tokens back from a miner and into your Metamask wallet.
            If you don't have any tokens to start with, please refer to <a href="https://www.krakint.com" target="_blank">Krakin't Web-Page</a>.
          </div>
          <div class="trade">
            <table style="width:63%">
              <tr>
                <td>
                  <label for="deposit">
                    Deposit KRK
                  </label><br>
                  <b-form-input
                      id="deposit"
                      v-model="deposit"
                      type="text"
                      placeholder="Amount"
                  />
                  <hr>

                  <div>
                    <b-button
                        :variant="'primary'"
                        @click="processDeposit"
                    >
                      Deposit
                    </b-button>
                    <img
                        v-show="isLoad"
                        src="https://media.giphy.com/media/2A6xoqXc9qML9gzBUE/giphy.gif"
                    >
                  </div>


                </td>
                <td>
                  <div style="opacity: 0">......................................</div>
                </td>
                <td>
                  <label for="withdraw">
                    Withdraw KRK
                  </label><br>
                  <b-form-input
                      id="withdraw"
                      v-model="withdraw"
                      type="text"
                      placeholder="Amount"
                  />
                  <hr>

                  <div>
                    <b-button
                        :variant="'primary'"
                        @click="processWithdraw"
                    >
                      Withdraw
                    </b-button>
                    <img
                        v-show="isLoad"
                        src="https://media.giphy.com/media/2A6xoqXc9qML9gzBUE/giphy.gif"
                    >
                  </div>

                </td>
              </tr>
            </table>

          </div>



        </div>


    </div>



    <div class="krakintext2" style="margin-top: 12vw;">
      <div>Your Address: {{ userAddress }}</div>
      <div>Total Burned: {{ totalBurned }} KRK</div>
      <div>Total Minted: {{ totalMinted }} KRK</div>
      <div>Number of Miners: {{ miners }}</div>
    </div>


    <div class="footer">
      <img src="img/cave_footer.svg" width="100%">
    </div>

  </div>

</template>

<script>
import web3 from '../contracts/web3';
import auctionBox from '../contracts/auctionBoxInstance';

function numberWithCommas(x) {
  return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function truncateNumber(x) {
  return Math.trunc(x * 1000) / 1000;
}

function formatNumber(x) {
  return x.replace(/\,/g, '');
}

function formatAddress(address){
  return address.substr(0,5)+"..."+address.substr(35);
}


export default {
  name: 'APP',
  created() {
    this.interval = setInterval(() => this.refreshData(), 6000);
  },
  data() {
    return {
      userAddress: 'Please install Metamask',
      miners: '',
      totalBurned: '',
      totalMinted: '',
      blockNumber: '',
      reward: 'Please install Metamask',
      deposit: '',
      withdraw: '',
    };
  },
  beforeMount() {
    this.refreshData();
  },
  methods: {
    refreshData(){
      this.userAddress = formatAddress(web3.eth.accounts.givenProvider.selectedAddress);
      const fromAddress = web3.eth.accounts.givenProvider.selectedAddress;

      auctionBox.methods
          .getPivot()
          .call()
          .then((n) => {
            this.miners = n;
          });
      auctionBox.methods
          .getTotalBurned()
          .call()
          .then((n) => {
            this.totalBurned = numberWithCommas(truncateNumber(web3.utils.fromWei(n, 'ether')));
          });
      auctionBox.methods
          .getTotalMinted()
          .call()
          .then((n) => {
            this.totalMinted = numberWithCommas(truncateNumber(web3.utils.fromWei(n, 'ether')));
          });
      auctionBox.methods
          .getCurrentBlockNumber()
          .call()
          .then((n) => {
            this.blockNumber = n;
          });
      auctionBox.methods
          .showReward(fromAddress)
          .call()
          .then((n) => {
            this.reward = numberWithCommas(truncateNumber(web3.utils.fromWei(n, 'ether')));
          });
    },

    processDeposit() {
      const fromAddress = web3.eth.accounts.givenProvider.selectedAddress;
      const amount = web3.utils.toWei(formatNumber(this.deposit), 'ether');
      this.deposit = '';

      auctionBox.methods
          .mine(amount).send({
        from: fromAddress,
      });
    },
    processWithdraw() {

      const fromAddress = web3.eth.accounts.givenProvider.selectedAddress;
      const amount = web3.utils.toWei(formatNumber(this.withdraw), 'ether');
      this.withdraw = '';

      auctionBox.methods
          .getReward(amount).send({
        from: fromAddress,
      });

    }

  },
};
</script>

<style>

.header {
  width: 100%;
  color: white;
  text-align: center;
}
.footer {
  width: 100%;
  color: white;
  text-align: center;
  left: 0;
  bottom: 0;
}

.logo_text{
  text-align: center;
}

.moveUp{
  margin-top: -30%;
}

.leftPadding{
  padding-left: 20px;
}

table {
  border-collapse: collapse;
  position: absolute;
  color: #74ff74;
  margin-top: 25px;
  font-size: 1.4vw;
}

th, td {
  width: 100px;
  overflow: hidden;
}


h1 {
  color:#00ff19;
  text-shadow: rgb(0, 0, 0) 3px 0px 0px, rgb(0, 0, 0) 2.83487px 0.981584px 0px, rgb(0, 0, 0) 2.35766px 1.85511px 0px, rgb(0, 0, 0) 1.62091px 2.52441px 0px, rgb(0, 0, 0) 0.705713px 2.91581px 0px, rgb(0, 0, 0) -0.287171px 2.98622px 0px, rgb(0, 0, 0) -1.24844px 2.72789px 0px, rgb(0, 0, 0) -2.07227px 2.16926px 0px, rgb(0, 0, 0) -2.66798px 1.37182px 0px, rgb(0, 0, 0) -2.96998px 0.42336px 0px, rgb(0, 0, 0) -2.94502px -0.571704px 0px, rgb(0, 0, 0) -2.59586px -1.50383px 0px, rgb(0, 0, 0) -1.96093px -2.27041px 0px, rgb(0, 0, 0) -1.11013px -2.78704px 0px, rgb(0, 0, 0) -0.137119px -2.99686px 0px, rgb(0, 0, 0) 0.850987px -2.87677px 0px, rgb(0, 0, 0) 1.74541px -2.43999px 0px, rgb(0, 0, 0) 2.44769px -1.73459px 0px, rgb(0, 0, 0) 2.88051px -0.838247px 0px;
}

body {
  background-color: #050000;
}

label{
  display: inline-block;
  margin-bottom: 0.5rem;
  color: #f8faf7;
  font-size: 1.3vw;
  font-weight: bold;
  -webkit-text-stroke: 1px #5d5a53;
}


.container{
  opacity: 1.0;
  max-width: 100% !important;
  padding-right: 0px !important;
  padding-left: 0px !important;
  margin-right: 0px !important;
  margin-left: 0px !important;
}

.console{
  background-color: #000000;
  text-align: center;
  border: 4px #00ff19 double;
  width: 50%;
  position: relative;
  margin-left: 23%;
  border-radius: 25px;
}

.krakintext{
  text-align: center;
  width: 50%;
  margin-left: 23%;
  color: #e9f0ee;
  margin-bottom: 60px;
  font-size: 1.7vw;
}

.krakintext2{
  text-align: center;
  width: 50%;
  margin-left: 23%;
  color: #e9f0ee;
  margin-bottom: 60px;
  font-size: 1.3vw;
  margin-top: 50px;
}


.welcome{
  font-size: 2.8vw;
  color: #f7dc69;
  -webkit-text-stroke-width: 1px;
  -webkit-text-stroke-color: #e8af21;
}

.stats{
  text-align: center;
  width: 50%;
  margin-left: 23%;
color: #fff;
}

.trade{
  position: relative;
  margin-bottom: 333px;
  margin-left: 23%;
}


h1,
h2 {
  font-weight: normal;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  display: inline-block;
  margin: 0 10px;
}

a {
  color: #42b983;
}

button {
  background-color: #008cba;
  color: white;
}

button:hover {
  color: #cacfd7 !important;
  background-color: #5d5952 !important;;
  border-color: #cacfd7 !important;
}

.btn-primary{
  color: #353130!important;
  background-color: #cacfd7!important;
  border-color: #5d5952!important;
}

.form-control{
  background-color: #cacfd7!important;
  max-width:200px;
  color: #000!important;

}

</style>
