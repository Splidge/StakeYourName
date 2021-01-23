# StakeYourName
 My project for the MarketMake 2021 Hackathon

Keep your ENS name secure with automatic renewals paid for by interest from deposited funds with Aave or with staking rewards from ETH2.0¹

## Key benefits:
- Automatic renewal²
- Cheaper gas costs with bulk renewal
- Short term renewals
- Deposited funds can be retrieved anytime

## Automatic renewal.
The smart contract will check when your ENS name needs renewal and automatically pay for the renewal² to keep your name(s) safe.

## Cheaper gas costs.
By using the ENS Bulk Renewal function StakeYourName can save on gas costs by renewing your name(s) alongside others due for renewal at the same time.

## Short Term Renewals.
Choose how long you want to renew your name for down to the minimum renewal time of 28 days. As ETH prices have been trending upwards over time³ why pre-pay for your name at exaggerated prices. Paying for a years rental on the 1st November 2020 would have cost 0.013 ETH, the same renewal on the 1st December 2020 would have cost 0.0084 ETH and on the 1st January 2021 only 0.0065 ETH. Within the space of 2 months the cost of renewal (measured in ETH) has halved. By renewing in shorter periods you're getting the cheaper price³ over time.

## Deposited funds can be retrieved anytime.
The option to lock in your original deposit, by doing this the contract will not be able to spend any of your original deposit leaving it availiable to withdraw at any time.

##The Future of StakeYourName.
**Phase 1** - Using interest earned from depositing tokens to Aave
**Phase 2** - Add the option to use staking rewards from ETH2.0
**Phase 3** - Integrate other subscription models to allow the users to pay for other services with interest/staking rewards

*Created by **Daniel Chilvers.** *

¹Staking not yet implemented
²Automatic renewal only works if the user has deposited enough funds to pay for the renewal, or if they've locked the funds that there's enough interest earned at the time of renewal. A warning message is displayed to the user at the time of registration if this is likely to happen given the funds they are depositing.
³ETH/USD prices may fluctuate, we can't gaurentee the best price every time. Given current ETH/USD price history shorter renewals would have been the cheapest way to renew over time. If a user thinks the ETH/USD price has peaked they may submit a manual renewal to lock in their desired price.
