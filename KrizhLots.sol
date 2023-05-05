// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";

contract KrizhLots {
    enum Progress { Idle, Active, Finishing }

    struct Status {
        Progress progress;
        uint pot;
        uint deadline;
        address winner;
    }

    uint public constant timeoutSeconds = 60;
    uint public bidValue = 1_000_000_000; // 1 GWei

    address public owner;

    Progress progress;
    uint deadline; // UNIX timestamp

    address[] players;
    mapping(address => uint) playerValues;
    mapping(uint => uint) usedValues;
    address winner;

    constructor() {
        owner = msg.sender;
    }

    function setBid(uint value) external {
        require(msg.sender == owner, "Only owner allowed");
        require(deadline == 0, "Can't set new bid value. The game is in progress");

        bidValue = value;
    }

    function getStatus() public view returns(Status memory) {
        return Status({
            progress: getProgress(),
            pot: address(this).balance,
            deadline: deadline,
            winner: winner
        });
    }

    function start() external {
        require(deadline == 0, "The game is already in progress");

        for (uint i = 0; i < players.length; i++) {
            usedValues[playerValues[players[i]]] = 0;
            playerValues[players[i]] = 0;
        }
        delete players;

        deadline = block.timestamp + timeoutSeconds;
        winner = address(0);
    }

    function bid(uint value) external payable {
        require(getProgress() == Progress.Active, "Cannot make the bid. The game is not in the active stage");
        require(value > 0, "Incorrect value. Required > 0");
        require(msg.value == bidValue, string.concat("Incorrect bid. Required: ", Strings.toString(bidValue)));
        require(playerValues[msg.sender] == 0, "The address has been already enrolled in this game");
        
        players.push(msg.sender);
        playerValues[msg.sender] = value;
        usedValues[value]++;
    }

    function finish() external {
        require(getProgress() == Progress.Finishing, "The game is not in the finishing stage");
        setWinner();

        if (winner != address(0)) {
            payable(winner).transfer(address(this).balance);
        }

        deadline = 0;
    }

    function getProgress() private view returns(Progress) {
        if (deadline == 0) {
            return Progress.Idle;
        }
        
        if (block.timestamp <= deadline) {
            return Progress.Active;
        }
        
        return Progress.Finishing;
    }

    function setWinner() private {
        for (uint i = 0; i < players.length; i++) {
            uint playerValue = playerValues[players[i]];
            if (usedValues[playerValue] == 1 && (winner == address(0) || playerValue < playerValues[winner])) {
                winner = players[i];
            }
        }
    }
}
