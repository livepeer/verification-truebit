const { promisify } = require("util")
const { uploadIPFS } = require("./ipfs")
const JobsManagerArtifact = require("../../build/contracts/JobsManager.json")

class JobsManagerWrapper {
    constructor(web3Wrapper, jobsManagerAddress, account) {
        this.web3Wrapper = web3Wrapper
        this.jobsManagerAddress = jobsManagerAddress
        this.account = account
    }

    async verify(dataIPFSHash) {
        const jobsManager = await this.getJobsManager()
        const gas = await jobsManager.verify.estimateGasAsync(dataIPFSHash)
        const txHash = await jobsManager.verify(dataIPFSHash, {from: this.account, gas: gas})
        const receipt = await this.web3Wrapper.waitForMinedTx(txHash)
        return receipt
    }

    async uploadAndVerify(file) {
        const res = await uploadIPFS(file)
        console.log(`Uploaded data to IPFS: ${res.hash}`)

        return await this.verify(res.hash)
    }

    async getJobsManager() {
        if (this.instance !== undefined) {
            return this.instance
        }

        this.instance = await this.web3Wrapper.getContractInstance(JobsManagerArtifact.abi, this.jobsManagerAddress)

        return this.instance
    }
}

module.exports = JobsManagerWrapper
