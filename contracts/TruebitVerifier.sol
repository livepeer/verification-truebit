pragma solidity ^0.4.17;

import "./ITrueBit.sol";

interface IVerifiable {
    // External functions
    function receiveVerification(uint256 _jobId, uint256 _claimId, uint256 _segmentNumber, bool _result) external;
}

contract TruebitVerifier {
    // Contract entry point into TrueBit system
    ITruebit public truebit;
    
    // IPFS hash used to download the WASM binary containing verification code
    // that is run by Truebit solvers and verifiers
    string public codeHash;
    // Root hash for the WASM binary file in IPFS
    bytes32 public codeRootHash;
    // String of identifiers that correspond to a video profiles defining
    // the required values for fields such as resolution, framerate, bitrate, etc.
    // for a transcoded video segment
    // In the simplest case, this string just contains a single video profile identifier
    string public transcodingOptions;

    event ReceivedVerification(bool passed);

    modifier onlyTruebit() {
        require(msg.sender == address(truebit));
        _;
    }

    uint nonce;
    IFilesystem filesystem;
    
    struct TaskData {
        uint256 jobId;
        uint256 claimId;
        uint256 segmentNumber;
        address receiver;
    }

    mapping (uint => TaskData) task_to_data;
    mapping (string => uint) result;

    constructor(address _trueBit, address _fs, string _codeHash, bytes32 _codeRootHash) public {
        truebit = ITruebit(_trueBit);
        filesystem = IFilesystem(_fs);
        codeHash = _codeHash;
        codeRootHash = _codeRootHash;
        // transcodingOptions = _transcodingOptions;
    }
    
    function blockNum() public view returns (uint) {
        return block.number;
    }
    
    event GotTask(string ipfshash, uint size);

    // ipfs hash, binary merkle root and size are all required here
    function verify(
        uint256 _jobId,
        uint256 _claimId,
        uint256 _segmentNumber,
        string _transcodingOptions,
        string _dataStorageHash,
        bytes32[2] _dataHashes
    ) external payable {
        bytes32 root = _dataHashes[0];
        uint size = uint(_dataHashes[1]);
        
        // The input files are stored in a "bundle", first we create it
        bytes32 bundle = filesystem.makeBundle(nonce++);
        // There are two needed files, first is the input file
        bytes32 input_file = filesystem.addIPFSFile("input.ts", size, _dataStorageHash, root, nonce++);
        filesystem.addToBundle(bundle, input_file);
        // There is also a file for output, it is just an empty file at the beginning of the task
        bytes32[] memory empty = new bytes32[](0);
        filesystem.addToBundle(bundle, filesystem.createFileWithContents("output.data", nonce++, empty, 0));
        // Also the task code is part of the bundle
        filesystem.finalizeBundleIPFS(bundle, codeHash, codeRootHash);

        // The parameters correspond to stack_size = 2**20, memory_size = 2**23, globals_size = 2**8, table_size = 2**20, call_size = 2**10
        uint task = truebit.addWithParameters(filesystem.getInitHash(bundle), 1, 1, idToString(bundle), 20, 23, 8, 20, 10);
        // Specify a file that has to be uploaded into the blockchain
        truebit.requireFile(task, hashName("output.data"), 0);
        // This is needed so that no extra files will be required afterwards
        truebit.commit(task);

        task_to_data[task].jobId = _jobId;
        task_to_data[task].claimId = _claimId;
        task_to_data[task].segmentNumber = _segmentNumber;
        task_to_data[task].receiver = msg.sender;

        emit GotTask(_dataStorageHash, size);
    }

    function getPrice() public pure returns (uint256) {
        return 0;
    }

    // this is the callback name
    function solved(uint id, bytes32[] files) external onlyTruebit {
        // could check the task id
        // remember_task = id;
        // filesystem.forwardData(files[0], this);
        TaskData storage t = task_to_data[id];
        bytes32[] memory arr = filesystem.getData(files[0]);
        IVerifiable(t.receiver).receiveVerification(t.jobId, t.claimId, t.segmentNumber, uint(arr[0]) > 0);
    }

    ///// Utils

    function idToString(bytes32 id) public pure returns (string) {
        bytes memory res = new bytes(64);
        for (uint i = 0; i < 64; i++) res[i] = bytes1(((uint(id) / (2**(4*i))) & 0xf) + 65);
        return string(res);
    }

    function makeMerkle(bytes arr, uint idx, uint level) internal pure returns (bytes32) {
        if (level == 0) return idx < arr.length ? bytes32(uint(arr[idx])) : bytes32(0);
        else return keccak256(makeMerkle(arr, idx, level-1), makeMerkle(arr, idx+(2**(level-1)), level-1));
    }

    function calcMerkle(bytes32[] arr, uint idx, uint level) internal returns (bytes32) {
        if (level == 0) return idx < arr.length ? arr[idx] : bytes32(0);
        else return keccak256(calcMerkle(arr, idx, level-1), calcMerkle(arr, idx+(2**(level-1)), level-1));
    }

    // assume 256 bytes?
    function hashName(string name) public pure returns (bytes32) {
        return makeMerkle(bytes(name), 0, 8);
    }

}

