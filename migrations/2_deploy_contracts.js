const TrueBitMock = artifacts.require("TrueBitMock")
const JobsManager = artifacts.require("JobsManager")

// Note: Placeholder IPFS hash
const CODE_HASH = "QmXKxSKhUZnmjb53HzS94arpshet3N5Kmct8JBAsgm9umR"
// Corresponds to bitrate = 6000k, framerate: 60fps, aspectratio: 16:9, resolution: 1280x720
const TRANSCODING_OPTIONS = "a7ac137a"

const deploy = async (deployer, artifact, ...args) => {
    await deployer.deploy(artifact, ...args)
    return await artifact.deployed()
}

module.exports = function(deployer) {
    deployer.then(async () => {
        const trueBit = await deploy(deployer, TrueBitMock)
        await deploy(deployer, JobsManager, trueBit.address, CODE_HASH, TRANSCODING_OPTIONS)
    })
}
