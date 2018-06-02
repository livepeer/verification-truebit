
var fs = require("fs")
var Web3 = require('web3')
var web3 = new Web3()
var ipfsAPI = require('ipfs-api')

var config = JSON.parse(fs.readFileSync("config.json"))

var host = config.host

var send_opt = {gas:4700000, from:config.base}

var w3provider = new web3.providers.WebsocketProvider('ws://' + host + ':8546')
web3.setProvider(w3provider)

var ipfs = ipfsAPI(config.ipfshost, '5001', {protocol: 'http'})

var filesystem = new web3.eth.Contract(JSON.parse(fs.readFileSync("../webasm-solidity/contracts/compiled/Filesystem.abi")), config.fs)
var contract = new web3.eth.Contract(JSON.parse(fs.readFileSync("./compiled/Task.abi")), config.post)

function arrange(arr) {
    var res = []
    var acc = ""
    arr.forEach(function (b) { acc += b; if (acc.length == 64) { res.push("0x"+acc); acc = "" } })
    if (acc != "") res.push("0x"+acc)
    console.log(res)
    return res
}

async function createFile(fname, buf) {
    var nonce = await web3.eth.getTransactionCount(config.base)
    var arr = []
    for (var i = 0; i < buf.length; i++) {
        if (buf[i] > 15) arr.push(buf[i].toString(16))
        else arr.push("0" + buf[i].toString(16))
    }
    console.log("Nonce", nonce, {arr:arrange(arr)})
    var tx = await filesystem.methods.createFileWithContents(fname, nonce, arrange(arr), buf.length).send(send_opt)
    var id = await filesystem.methods.calcId(nonce).call(send_opt)
    return id
}

async function outputFile(id) {
    var lst = await filesystem.methods.getData(id).call(send_opt)
    console.log("File data for", id, "is", lst)
    // var dta = await filesystem.methods.debug_forwardData(id, config.coindrop).call(send_opt)
    // console.log("DEBUG: ", dta)
}

var wasm_path = "../ocaml-offchain/interpreter/wasm"

var execFile = require('child_process').execFile

function exec(args) {
    return new Promise(function (cont,err) {
        execFile(wasm_path, args, function (error, stdout, stderr) {
            if (stderr) console.log('error', stderr, args)
            if (stdout) console.log('output', stdout, args)
            if (error) err(error)
            else cont(stdout)
        })
    })
}

function uploadIPFS(fname) {
    return new Promise(function (cont,err) {
        fs.readFile(fname, function (err, buf) {
            ipfs.files.add([{content:buf, path:fname}], function (err, res) {
                if (err) console.log(err)
                cont(res[0])
            })
        })
    })
}

async function createIPFSFile(fname) {
    var hash = await uploadIPFS(fname)
    var info = JSON.parse(await exec(["-hash-file", fname]))
    return {size:info.size, hash:hash.hash, root:info.root}
}

function stringToBytes(str) {
    var lst = Buffer.from(str)
    return "0x" + lst.toString("hex")
}

var fname = process.argv[2] || "input.ts"

async function doPost(fname) {
    
    var file = await createIPFSFile(fname)
    console.log("Uploaded to IPFS", file)
    var file_hash = await contract.methods.submit(file.hash, file.root, file.size).call(send_opt)
    console.log(file_hash)
    var tx = await contract.methods.submit(file.hash, file.root, file.size).send(send_opt)
    console.log(tx)
    contract.events.GotFiles(function (err,ev) {
        if (err) return console.log(err)
        console.log("Files", ev.returnValues)
        var files = ev.returnValues.files
        files.forEach(outputFile)
    })
    contract.events.Consuming(function (err,ev) {
        if (err) return console.log(err)
        console.log("Consuming", ev.returnValues)
        process.exit(0)
    })
    // process.exit(0)
}

doPost(fname)




