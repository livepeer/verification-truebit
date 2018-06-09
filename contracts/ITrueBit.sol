pragma solidity ^0.4.17;

interface IFilesystem {

   function addIPFSFile(string name, uint size, string hash, bytes32 root, uint nonce) external returns (bytes32);
   function createFileWithContents(string name, uint nonce, bytes32[] arr, uint sz) external returns (bytes32);
   function getSize(bytes32 id) external view returns (uint);
   function getRoot(bytes32 id) external view returns (bytes32);
   function getData(bytes32 id) external view returns (bytes32[]);
   function forwardData(bytes32 id, address a) external;
   
   function makeBundle(uint num) external view returns (bytes32);
   function addToBundle(bytes32 id, bytes32 file_id) external returns (bytes32);
   function finalizeBundleIPFS(bytes32 id, string file, bytes32 init) external;
   function getInitHash(bytes32 bid) external view returns (bytes32);
   
   function debug_finalizeBundleIPFS(bytes32 id, string file, bytes32 init) external returns (bytes32, bytes32, bytes32, bytes32, bytes32);
   
}

interface ITruebit {
   function add(bytes32 init, /* CodeType */ uint8 ct, /* Storage */ uint8 cs, string stor) external returns (uint);
   function addWithParameters(bytes32 init, /* CodeType */ uint8 ct, /* Storage */ uint8 cs, string stor, uint8 stack, uint8 mem, uint8 globals, uint8 table, uint8 call) external returns (uint);
   function requireFile(uint id, bytes32 hash, /* Storage */ uint8 st) external;
   function commit(uint id) external;
}

