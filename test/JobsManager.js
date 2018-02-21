const JobsManager = artifacts.require("JobsManager")

contract("JobsManager", accounts => {
    // Note: Placeholder address for TrueBit
    const TRUE_BIT = accounts[1]
    // Note: Placeholder IPFS hash
    const CODE_HASH = "QmXKxSKhUZnmjb53HzS94arpshet3N5Kmct8JBAsgm9umR"
    // Corresponds to bitrate = 6000k, framerate: 60fps, aspectratio: 16:9,. resolution: 1280x720
    const TRANSCODING_OPTIONS = "a7ac137a"

    describe("constructor", () => {
        it("creates contract with provided parameters", async () => {
            const jobsManager = await JobsManager.new(TRUE_BIT, CODE_HASH, TRANSCODING_OPTIONS)

            assert.equal(await jobsManager.trueBit.call(), TRUE_BIT, "wrong trueBit address")
            assert.equal(await jobsManager.codeHash.call(), CODE_HASH, "wrong codeHash")
            assert.equal(await jobsManager.transcodingOptions.call(), TRANSCODING_OPTIONS, "wrong transcodingOptions")
        })
    })
})
