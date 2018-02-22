const { promisify } = require("util")
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

module.exports = {
    uploadIPFS
}
