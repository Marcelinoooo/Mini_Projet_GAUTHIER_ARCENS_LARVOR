// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Election is Ownable(msg.sender), AccessControl {
    bytes32 public constant PRESIDENT_ROLE = keccak256("PRESIDENT_ROLE");
    bytes32 public constant SCRUTINEER_ROLE = keccak256("SCRUTINEER_ROLE");
    bytes32 public constant SECRETARY_ROLE = keccak256("SECRETARY_ROLE");

    struct Resolution {
        uint id;
        string title;
        uint votesFor;
        uint votesAgainst;
        uint votesNeutral;
        bool open;
    }

    mapping(uint => Resolution) public resolutions;
    mapping(uint => mapping(address => bool)) public voterRegistry;
    uint public resolutionCount;

  

    function addRole(address account, bytes32 role) public onlyOwner {
        _grantRole(role, account);
    }

    function addResolution(string memory title) public onlyRole(SECRETARY_ROLE) {
        resolutionCount++;
        resolutions[resolutionCount] = Resolution(resolutionCount, title, 0, 0, 0, true);
    }

    function vote(uint resolutionId, uint8 voteType) public {
        require(voterRegistry[resolutionId][msg.sender] == false, "Already voted");
        require(voteType >= 1 && voteType <= 3, "Invalid vote type");
        require(resolutions[resolutionId].open, "Voting is closed");

        Resolution storage resolution = resolutions[resolutionId];

        if (voteType == 1) {
            resolution.votesFor++;
        } else if (voteType == 2) {
            resolution.votesAgainst++;
        } else if (voteType == 3) {
            resolution.votesNeutral++;
        }

        voterRegistry[resolutionId][msg.sender] = true;
    }

    function closeResolution(uint resolutionId) public onlyRole(PRESIDENT_ROLE) {
        resolutions[resolutionId].open = false;
    }

    function getResults(uint resolutionId) public view returns (uint, uint, uint) {
        require(!resolutions[resolutionId].open, "Voting still open");
        Resolution storage resolution = resolutions[resolutionId];
        return (resolution.votesFor, resolution.votesAgainst, resolution.votesNeutral);
    }
}
