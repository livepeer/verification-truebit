require("dotenv").config()

const path = require("path")
const prompt = require("prompt-sync")()
const Web3 = require("web3")
const Web3Wrapper = require("./lib/web3Wrapper")
const JobsManagerWrapper = require("./lib/jobsManagerWrapper")
const { uploadIPFS } = require("./lib/ipfs")

const provider = new Web3.providers.HttpProvider("http://localhost:8545")
const correctDataFile = path.resolve(__dirname, "../data/correct.ts")

const run = async () => {
    if (process.env.JOBSMANAGER_ADDRESS === undefined) {
        abort("Must pass in the JobsManager contract address")
    }

    if (process.env.ACCOUNT === undefined) {
        abort("Must pass in a valid Ethereum account address")
    }

    const web3Wrapper = new Web3Wrapper(provider)
    const nodeType = await web3Wrapper.getNodeType()

    if (!nodeType.match(/TestRPC/i)) {
        // Not connected to TestRPC
        // User must unlock account

        const success = unlock(process.env.ACCOUNT, process.env.PASSWORD, web3Wrapper)
        if (!success) {
            abort("Failed to unlock account")
        }
    }

    console.log(`Account ${process.env.ACCOUNT} unlocked`)

    const jobsManager = new JobsManagerWrapper(web3Wrapper, process.env.JOBSMANAGER_ADDRESS, process.env.ACCOUNT)

    await jobsManager.uploadAndVerify(correctDataFile)

    console.log("Submitted for verification")
}

const abort = msg => {
    console.log(msg || "Error occured")
    process.exit(1)
}

const unlock = async (account, password, web3Wrapper) => {
    const success = await web3Wrapper.unlockAccount(account, password)
    if (!success) {
        // Prompt for password if default password fails
        password = prompt("Password: ")

        return await web3Wrapper.unlockAccount(account, password)
    } else {
        return true
    }
}

run().catch(console.log)
