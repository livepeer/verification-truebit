# verification-truebit

WIP PoC verification system for the Livepeer protocol using Truebit

![livepeer-truebit](./livepeer-truebit.png)

## Setup

The client requires IPFS which can be installed [here](https://ipfs.io/docs/install/).

Make sure to clone and build the Truebit off-chain WASM interpreter [here](https://github.com/TrueBitFoundation/ocaml-offchain).

```
git clone https://github.com/livepeer/verification-truebit.git
cd verification-truebit
npm install
```

## Deploying

The Truffle migration scripts will update a `.env` file with the deployed contract addresses and an account to use.

```
# Compile contracts
npm run compile

# Deploy contracts
npm run migrate
```

## Running the client

```
# Start IPFS daemon
ipfs daemon

# Upload video segment data to IPFS and submit for verification
npm run uploadAndVerify
```
