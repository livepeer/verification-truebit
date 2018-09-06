pragma solidity ^0.4.18;

import "./contracts/ITrueBit.sol";

contract Task {
   uint nonce;
   ITruebit truebit;
   IFilesystem filesystem;

   string code;
   bytes32 init;

   mapping (uint => string) task_to_ipfs;
   mapping (string => uint) result;
   
   event GotFiles(bytes32[] files);
   event Consuming(bytes32[] arr);
   event Submitted(uint task, bytes32 root);
   
   constructor(address tb, address fs, string code_address, bytes32 init_hash) public {
      truebit = ITruebit(tb);
      filesystem = IFilesystem(fs);
      code = code_address;     // address for wasm file in IPFS
      init = init_hash;        // the canonical hash
   }

   // add new task for a file
   function submit(string hash, bytes32 root, uint size) public {
      bytes32 input_file = filesystem.addIPFSFile("input.ts", size, hash, root, nonce++);
      bytes32 bundle = filesystem.makeBundle(nonce++);
      filesystem.addToBundle(bundle, input_file);
      bytes32[] memory empty = new bytes32[](0);
      filesystem.addToBundle(bundle, filesystem.createFileWithContents("output.data", nonce++, empty, 0));
      filesystem.finalizeBundleIPFS(bundle, code, init);
      
      uint task = truebit.addWithParameters(filesystem.getInitHash(bundle), 1, 1, idToString(bundle), 20, 21, 8, 20, 10);
      truebit.requireFile(task, hashName("output.data"), 0);
      truebit.commit(task);

      task_to_ipfs[task] = hash;

      emit Submitted(task, filesystem.getRoot(input_file));
   }

   /*
   uint remember_task;
   
   function consume(bytes32, bytes32[] arr) public {
      Consuming(arr);
      require(Filesystem(msg.sender) == filesystem);
      result[task_to_ipfs[remember_task]] = uint(arr[0]);
   }*/

   // this is the callback name
   function solved(uint id, bytes32[] files) public {
      // could check the task id
      require(ITruebit(msg.sender) == truebit);
      // remember_task = id;
      bytes32[] memory arr = filesystem.getData(files[0]);
      emit GotFiles(files);
      emit Consuming(arr);
      result[task_to_ipfs[id]] = uint(arr[0]);
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

