const { promisify } = require("util")
const shell = require("shelljs")
const fs = require("fs")
const ipfsAPI = require("ipfs-api")

const uploadIPFS = async file => {
    const ipfs = ipfsAPI({
        host: "localhost",
        port: "5001",
        protocol: "http"
    })

    const buf = await promisify(fs.readFile)(file)

    return new Promise((resolve, reject) => {
        ipfs.files.add([{content: buf, path: file}], (err, res) => {
            if (err) {
                reject(err)
            } else {
                resolve(res[0])
            }
        })
    })
}

const createIPFSFile = async (file, wasmPath) => {
    const res = uploadIPFS(file)
    const info = JSON.parse(await promisify(shell.exec)(`${wasmPath} -hash-file ${file}`))

    console.log(`Created IPFS file - Name: ${file} Size: ${info.size} IPFS Hash: ${res.hash} Data: ${info.root}`)

    return {
        filename: file,
        size: info.size,
        ipfsHash: res.hash,
        root: info.root
    }
}

module.exports = {
    uploadIPFS,
    createIPFSFile
}
