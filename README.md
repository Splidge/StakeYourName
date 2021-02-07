# StakeYourName
My project for the MarketMake 2021 Hackathon

Keep your ENS name secure with automatic renewals paid for by interest from deposited funds with Aave or with staking rewards from ETH2.0¹

## Key benefits:
- Automatic renewal²
- Cheaper gas costs
- Short term renewals
- Deposited funds can be retrieved anytime

### Automatic renewal.
The smart contract will check when your ENS name needs renewal and automatically pay for the renewal² to keep your name(s) safe.

### Cheaper gas costs.
There are various ways StakeYourName helps save gas costs and many more way to be impletement in the future. Some of these are by grouping users by the tokens they've edposited we can exchange them in bulk, thereby sharing the gas costs between the users, this is key for low-value transactions such a ENS name renewal where the gas costs involved can frequently be higher than the service you want to pay for. 

### Short Term Renewals.
Choose how long you want to renew your name for down to the minimum renewal time of 28 days. As ETH prices have been trending upwards over time³ why pre-pay for your name at exaggerated prices. Paying for a years rental on the 1st November 2020 would have cost 0.013 ETH, the same renewal on the 1st December 2020 would have cost 0.0084 ETH and on the 1st January 2021 only 0.0065 ETH. Within the space of 2 months the cost of renewal (measured in ETH) has halved. By renewing in shorter periods you're getting the cheaper price³ over time.

### Deposited funds can be retrieved anytime.
The option to lock in your original deposit, by doing this the contract will not be able to spend any of your original deposit leaving it availiable to withdraw at any time.

## The Future of StakeYourName.
- [x] **Phase 1.0** - Using interest earned from depositing tokens to Aave
- [ ] **Phase 1.1** - Integrate the Ethereum Alarm Service
- [ ] **Phase 1.5** - Add support for domains other than .eth
- [ ] **Phase 2.0** - Add the option to use staking rewards from ETH2.0
- [ ] **Phase 3.0** - Integrate other subscription models to allow the users to pay for other services with interest/staking rewards

### Integrating the Ethereum Alarm Serivce
This is a key milestone for the project and would greatly enhance the service offered. The aim of this would initially be so that StakeYourName could be scheduled to run at repeat intervals however the integration could also be offered to users. This would mean that you could deposit some assets into your vault, specify a contract you want to schedule and how often you want it to be scheduled, StakeYourName would then handle creating the Ethereum Alarm Serivce call and handle the payments.

### Beta test
To use the test version you need to set Metamask to the Kovan testnet, you can get some KETH from https://faucet.kovan.network/
Then you can mint some test tokens at https://testnet.aave.com/faucet
The testnet version is currently active at https://stakeyourname.webflow.io/ 
There isn't much to do on there right now because there isn't an ENS implementation on Kovan, but the names alice.eth, bob.eth and a couple of others have been implemented on a simulated ENS contract. This test version is undergoing live improvements and may be taken down or broken beyond repair at any time.


`A name not renewed may be lost forever` - _Abraham Lincoln_


_Created by **Daniel Chilvers.**_


<sub>¹Staking not yet implemented<sub>\
<sub>²Automatic renewal only works if the user has deposited enough funds to pay for the renewal, or if they've locked the funds that there's enough interest earned at the time of renewal. A warning message is displayed to the user at the time of registration if this is likely to happen given the funds they are depositing.<sub>\
<sub>³ETH/USD prices may fluctuate, we can't gaurentee the best price every time. Given current ETH/USD price history shorter renewals would have been the cheapest way to renew over time. If a user thinks the ETH/USD price has peaked they may submit a manual renewal to lock in their desired price.<sub>
