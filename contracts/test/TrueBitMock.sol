pragma solidity ^0.4.17;


contract TrueBitMock {
    event Add(string codeHash, string dataIPFSHash);

    function add(string _codeHash, string _dataIPFSHash) external {
        Add(_codeHash, _dataIPFSHash);
    }
}
