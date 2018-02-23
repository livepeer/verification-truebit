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

## Building a WASM Binary

This project currently uses an [ffprobe](https://ffmpeg.org/ffprobe.html) WASM binary for the Truebit task.

You can use the Truebit [WASM computation layer](https://github.com/TrueBitFoundation/wasm-computation-layer) to setup all
the dependencies needed to build a Truebit compatible WASM binary.

Once you have all the dependencies from the Truebit WASM Computation Layer set up, you can build a Truebit compatible ffprobe WASM binary and
observe the output for the directory that the WASM binary will be stored in:

```
bash scripts/build_ffprobe_wasm.sh
```

The goal is to replace the ffprobe WASM binary with a program that wraps ffprobe such that the output of the computation can be written to an output file.

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
