pragma solidity ^0.4.17;


contract IVerifiable {
    function receiveVerification(uint256 _jobId, uint256 _claimId, uint256 _segmentNumber, string _transcodingOptions) external;
}
