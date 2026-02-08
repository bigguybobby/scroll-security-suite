// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SecurityOracle
/// @notice On-chain security scoring oracle for Scroll contracts
contract SecurityOracle {
    struct Score {
        uint8 value; // 0-100
        uint256 timestamp;
        string details; // IPFS hash
    }

    mapping(address => Score[]) public scores;
    mapping(address => bool) public analyzers;
    address public owner;

    event ScoreUpdated(address indexed target, uint8 score, address indexed analyzer);
    event AnalyzerAdded(address indexed analyzer);
    event AlertRaised(address indexed target, string reason, uint8 severity);

    modifier onlyOwner() { require(msg.sender == owner, "not owner"); _; }
    modifier onlyAnalyzer() { require(analyzers[msg.sender], "not analyzer"); _; }

    constructor() { owner = msg.sender; analyzers[msg.sender] = true; }

    function addAnalyzer(address a) external onlyOwner { analyzers[a] = true; emit AnalyzerAdded(a); }

    function updateScore(address target, uint8 value, string calldata details) external onlyAnalyzer {
        require(value <= 100, "max 100");
        scores[target].push(Score(value, block.timestamp, details));
        emit ScoreUpdated(target, value, msg.sender);
    }

    function raiseAlert(address target, string calldata reason, uint8 severity) external onlyAnalyzer {
        emit AlertRaised(target, reason, severity);
    }

    function getLatestScore(address target) external view returns (uint8) {
        uint256 len = scores[target].length;
        if (len == 0) return 0;
        return scores[target][len - 1].value;
    }
}
