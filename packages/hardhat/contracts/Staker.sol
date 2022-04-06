// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    // Balance of user's stacked funds
    mapping(address => uint256) public balances;

    // Staking threshold
    uint256 public constant threshold = 1 ether;

    // Staking Deadline
    uint256 public deadline = block.timestamp + 72 hours;

    //Contract Event - (Stake)
    event Stake(address, uint256);

    bool openForWithdraw;
    bool executed = false;

    modifier notCompleted() {
        bool prepare = exampleExternalContract.completed();
        require(!prepare, "you can't withdraw or execute");
        _;
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
    function stake() public payable notCompleted {
        balances[msg.sender] += msg.value;
        balances[address(this)] += msg.value;

        emit Stake(msg.sender, msg.value);
    }

    function stake(address account, uint256 amount) private {
        balances[account] += amount;
        balances[address(this)] += amount;

        emit Stake(account, amount);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
    function execute() public notCompleted {
        require(block.timestamp >= deadline, "Try later");
        if (balances[address(this)] >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
            openForWithdraw = false;
        } else {
            openForWithdraw = true;
        }
    }

    // Add a `withdraw()` function to let users withdraw their balance
    function withdraw() public payable notCompleted {
        (bool sent, ) = msg.sender.call{value: balances[msg.sender]}("");
        require(sent, "Failed to send Ether");
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable notCompleted {
        stake(msg.sender, msg.value);
    }
}

