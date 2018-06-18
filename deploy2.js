
var fs = require("fs")
var Web3 = require('web3')
var web3 = new Web3()

var dir = "./compiled/"

var code = "0x" + fs.readFileSync(dir + "TruebitVerifier.bin")
var abi = JSON.parse(fs.readFileSync(dir + "TruebitVerifier.abi"))

var config = JSON.parse(fs.readFileSync("../webasm-solidity/node/config.json"))

var host = config.host

var send_opt = {gas:4700000, from:config.base}

if (host == "ipc") {
    var net = require('net')
    provider = new web3.providers.IpcProvider(config.ipc, net)
}
else provider = new web3.providers.HttpProvider('http://' + host + ':8545')

web3.setProvider(provider)

var filesystem = new web3.eth.Contract(JSON.parse(fs.readFileSync("../webasm-solidity/contracts/compiled/Filesystem.abi")), config.fs)

var control_addr = JSON.parse(fs.readFileSync("../livepeer-proto/build/contracts/Controller.json")).networks[4].address
// var control_addr = JSON.parse(fs.readFileSync("../livepeer-proto/build/contracts/Controller.json")).networks[1529093364029].address

//                              "0x8d49ec5b95c804e4ec8f17e26166be63175cafd8"

var controller = new web3.eth.Contract(JSON.parse(fs.readFileSync("../livepeer-proto/build/contracts/Controller.json")).abi, control_addr)

async function doDeploy() {
    var send_opt = {gas:4700000, from:config.base}
    var info = JSON.parse(fs.readFileSync("info.json"))
    // var init_hash = "0x0dc2d39106f5f0165019f9acfc0006976928d5c33d5ca0b165a256db30416e39"
    // var code_address = 'QmToCAmaHkz78LFD4tZV43wNv9FAQRxWCtCSecKvWsJMef'
    var contract = await new web3.eth.Contract(abi).deploy({data: code, arguments:[config.tasks, config.fs, info.ipfshash, info.codehash]}).send(send_opt)
    config.post = contract.options.address
    console.log(JSON.stringify(config))
    contract.setProvider(provider)
    
    var tx = await controller.methods.setContractInfo(web3.utils.keccak256("Verifier"), config.post, "0x00").send(send_opt)
    console.log(tx)
    
    var addr = await controller.methods.getContract(web3.utils.keccak256("Verifier")).call(send_opt)
    console.log("Controller", control_addr)
    console.log("testing", addr)
    
    var r_addr = await controller.methods.getContract(web3.utils.keccak256("RoundsManager")).call(send_opt)
    console.log("rounds manager", r_addr)
    
    var paused = await controller.methods.paused().call(send_opt)
    
    if (paused) await controller.methods.unpause().send(send_opt)

    var paused = await controller.methods.paused().call(send_opt)
    console.log("is paused", paused)

    var rman = new web3.eth.Contract(JSON.parse(fs.readFileSync("../livepeer-proto/build/contracts/RoundsManager.json")).abi, r_addr)
//    console.log("setting rounds", await rman.methods.setRoundLength(10).send(send_opt))

    console.log("cur round", await rman.methods.currentRound().call(send_opt))
    
    console.log("bnum", await rman.methods.blockNum().call(send_opt))
    
    console.log("round init", await rman.methods.currentRoundInitialized().call(send_opt))
    console.log("round locked", await rman.methods.currentRoundLocked().call(send_opt))
    console.log("round start block", await rman.methods.currentRoundStartBlock().call(send_opt))
    
    contract.events.GotTask(function (err,ev) {
        if (err) return console.log(err)
        console.log("Got event", ev)
    })
    
//    console.log("round debug", await rman.methods.debug().call(send_opt))


//    process.exit(0)
}

doDeploy()



