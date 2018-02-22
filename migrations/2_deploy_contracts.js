const fs = require("fs")
const path = require("path")
const { promisify } = require("util")

const TrueBitMock = artifacts.require("TrueBitMock")
const JobsManager = artifacts.require("JobsManager")

// Note: Placeholder IPFS hash
const CODE_HASH = "QmXKxSKhUZnmjb53HzS94arpshet3N5Kmct8JBAsgm9umR"
// Note: Placeholder root hash
const CODE_ROOT_HASH = web3.sha3("hello")
// Corresponds to bitrate = 6000k, framerate: 60fps, aspectratio: 16:9, resolution: 1280x720
const TRANSCODING_OPTIONS = "a7ac137a"

const ENV_FILE = path.resolve(__dirname, "../.env")

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
        const trueBit = await deploy(deployer, TrueBitMock)
        const jobsManager = await deploy(deployer, JobsManager, trueBit.address, CODE_HASH, CODE_ROOT_HASH, TRANSCODING_OPTIONS)

        await updateEnv(accounts[0], jobsManager.address, trueBit.address)
    })
}
