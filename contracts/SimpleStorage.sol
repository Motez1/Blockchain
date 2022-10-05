// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


// A simple smart contract that allows to store the state 
// of a balance variable, add and subtract an amount from it

contract SimpleStorage {
    uint256 public MotezBalance;

    function setBalance(uint256 _amount) public {
        MotezBalance = _amount;
    }

    function addToBalance(uint256 _amount) public {
        MotezBalance += _amount;
    }

    function subFromBalance(uint256 _amount) public {
        MotezBalance -= _amount;
    }

    function getBalance() public view returns (uint256){
        return MotezBalance;
    }
}