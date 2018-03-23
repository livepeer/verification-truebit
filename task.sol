
pragma solidity ^0.4.18;

interface Filesystem {

   function addIPFSFile(string name, uint size, string hash, bytes32 root, uint nonce) public returns (bytes32);
   function createFileWithContents(string name, uint nonce, bytes32[] arr, uint sz) public returns (bytes32);
   function getSize(bytes32 id) public view returns (uint);
   function getRoot(bytes32 id) public view returns (bytes32);
   function forwardData(bytes32 id, address a) public;
   
   // function makeSimpleBundle(uint num, address code, bytes32 code_init, bytes32 file_id) public returns (bytes32);
   
   function makeBundle(uint num) public view returns (bytes32);
   function addToBundle(bytes32 id, bytes32 file_id) public returns (bytes32);
   function finalizeBundleIPFS(bytes32 id, string file, bytes32 init) public;
   function getInitHash(bytes32 bid) public view returns (bytes32);
   
   function debug_finalizeBundleIPFS(bytes32 id, string file, bytes32 init) public returns (bytes32, bytes32, bytes32, bytes32, bytes32);
   
}

interface Truebit {
   function add(bytes32 init, /* CodeType */ uint8 ct, /* Storage */ uint8 cs, string stor) public returns (uint);
   function addWithParameters(bytes32 init, /* CodeType */ uint8 ct, /* Storage */ uint8 cs, string stor, uint8 stack, uint8 mem, uint8 globals, uint8 table, uint8 call) public returns (uint);
   function requireFile(uint id, bytes32 hash, /* Storage */ uint8 st) public;
}

contract Task {
   uint nonce;
   Truebit truebit;
   Filesystem filesystem;

   string code;
   bytes32 init;

   mapping (uint => string) task_to_ipfs;
   mapping (string => uint) result;
   
   event GotFiles(bytes32[] files);
   event Consuming(bytes32[] arr);
   
   function Task(address tb, address fs, string code_address, bytes32 init_hash) public {
      truebit = Truebit(tb);
      filesystem = Filesystem(fs);
      code = code_address;     // address for wasm file in IPFS
      init = init_hash;        // the canonical hash
   }

   // add new task for a file
   function submit(string hash, bytes32 root, uint size) public returns (bytes32) {
      uint num = nonce;
      nonce++;
      bytes32 input_file = filesystem.addIPFSFile("input.ts", size, hash, root, num);
      bytes32 bundle = filesystem.makeBundle(num);
      filesystem.addToBundle(bundle, input_file);
      bytes32[] memory empty = new bytes32[](0);
      filesystem.addToBundle(bundle, filesystem.createFileWithContents("output.data", num+1000000000, empty, 0));
      filesystem.finalizeBundleIPFS(bundle, code, init);
      
      uint task = truebit.addWithParameters(filesystem.getInitHash(bundle), 1, 1, idToString(bundle), 20, 25, 8, 20, 10);
      truebit.requireFile(task, hashName("output.data"), 0);

      task_to_ipfs[task] = hash;

      return filesystem.getRoot(input_file);
   }
   
   uint remember_task;
   
   function consume(bytes32, bytes32[] arr) public {
      Consuming(arr);
      require(Filesystem(msg.sender) == filesystem);
      result[task_to_ipfs[remember_task]] = uint(arr[0]);
   }

   // this is the callback name
   function solved(uint id, bytes32[] files) public {
      // could check the task id
      require(Truebit(msg.sender) == truebit);
      remember_task = id;
      filesystem.forwardData(files[0], this);
      GotFiles(files);
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

