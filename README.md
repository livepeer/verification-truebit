# verification-truebit

WIP PoC verification system for the Livepeer protocol using Truebit

![livepeer-truebit](./livepeer-truebit.png)

## Deploying

The Truffle migration scripts will update a `.env` file with the deployed contract addresses and an account to use.

```
# Compile contracts
npm run compile

# Deploy contracts
npm run migrate
```

## Running the client

The client requires IPFS which can be installed [here](https://ipfs.io/docs/install/).

```
# Start IPFS daemon
ipfs daemon

# Upload video segment data to IPFS and submit for verification
npm run uploadAndVerify
```
