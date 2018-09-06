pragma solidity ^0.4.17;

contract IVerifiable {
    function receiveVerification(string _transcodingOptions) external;
    function solved(uint id, bytes32[] files) external;
}

