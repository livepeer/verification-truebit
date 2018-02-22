const Web3 = require("web3")
const { promisify } = require("util")

const POLLING_INTERVAL_MS = 1200

class Web3Wrapper {
    constructor(provider) {
        this.web3 = new Web3()
        this.web3.setProvider(provider)
    }

    async getNodeType() {
        const result = await promisify(this.web3.version.getNode, {multiArgs: true})()
        return result[0]
    }

    async unlockAccount(account, password) {
        // Unlock permanently. This might not be ideal security wise...
        const success = this.web3.personal.unlockAccount(account, password, 0)
        return success
    }

    async getTransactionReceipt(txHash) {
        const receipt = await promisify(this.web3.eth.getTransactionReceipt)(txHash)
        return receipt
    }

    async getContractInstance(abi, address) {
        const contractExists = await this.contractExistsAtAddress(address)
        if (!contractExists) {
            throw new Error(`No contract found at address ${address}`)
        }

        const contractInstance = this.web3.eth.contract(abi).at(address)

        const allFnAbi = abi.filter(fn => fn.type == "function")
        allFnAbi.forEach(fnAbi => {
            if (fnAbi.constant) {
                const callFn = contractInstance[fnAbi.name].call
                contractInstance[fnAbi.name].callAsync = promisify(callFn, contractInstance)
            } else {
                const estimateGasFn = contractInstance[fnAbi.name].estimateGas
                contractInstance[fnAbi.name].estimateGasAsync = async (...args) => {
                    const gas = await promisify(estimateGasFn, contractInstance)(...args)
                    // Gas estimate + 10%
                    return gas + Math.floor(.1 * gas)
                }
            }
        })

        return contractInstance
    }

    async contractExistsAtAddress(address) {
        const code = this.web3.eth.getCode(address)
        // Matches 0x followed by 0-40 additional zeros
        const isEmptyCode = /^0x0{0,40}$/i.test(code)

        return !isEmptyCode
    }

    async waitForMinedTx(txHash) {
        let receipt = this.web3.eth.getTransactionReceipt(txHash)
        while (!receipt || !receipt.blockNumber) {
            await new Promise(resolve => {
                setTimeout(resolve, POLLING_INTERVAL_MS)
            })

            receipt = this.web3.eth.getTransactionReceipt(txHash)
        }

        if (receipt.status === "0x0") {
            throw new Error(`Tx ${txHash} failed.`)
        }

        return receipt
    }
}

module.exports = Web3Wrapper
