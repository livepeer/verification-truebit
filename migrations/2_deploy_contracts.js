const fs = require("fs")
const path = require("path")
const { promisify } = require("util")
const { createIPFSFile } = require("../client/lib/ipfs")

const TrueBitMock = artifacts.require("TrueBitMock")
const JobsManager = artifacts.require("JobsManager")

// Corresponds to bitrate = 6000k, framerate: 60fps, aspectratio: 16:9, resolution: 1280x720
const TRANSCODING_OPTIONS = "a7ac137a"

const ENV_FILE = path.resolve(__dirname, "../.env")
const WASM_FILE = path.resolve(__dirname, "../data/verification.wasm")
const WASM_PATH = path.resolve(__dirname, "../../ocaml-offchain/interpreter/wasm")

const deploy = async (deployer, artifact, ...args) => {
    await deployer.deploy(artifact, ...args)
    return await artifact.deployed()
}

const updateEnv = async (account, jobsManagerAddress, trueBitAddress) => {
    return await promisify(fs.writeFile)(
        ENV_FILE,
        `ACCOUNT=${account}\nJOBSMANAGER_ADDRESS=${jobsManagerAddress}\nTRUEBIT_ADDRESS=${trueBitAddress}`
    )
}

module.exports = function(deployer, network, accounts) {
    deployer.then(async () => {
        // Upload global WASM binary for Livepeer protocol
        const res = await createIPFSFile(WASM_FILE, WASM_PATH)
        const trueBit = await deploy(deployer, TrueBitMock)
        const jobsManager = await deploy(deployer, JobsManager, trueBit.address, res.ipfsHash, res.root, TRANSCODING_OPTIONS)

        await updateEnv(accounts[0], jobsManager.address, trueBit.address)
    })
}
