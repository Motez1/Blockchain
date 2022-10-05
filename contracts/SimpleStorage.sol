// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract SimpleStorage {
    uint256 public MotezBalance;

    function addToBalance(uint256 _amount) public {
        MotezBalance += _amount;
    }

    function subFromBalance(uint256 _amount) public {
        MotezBalance -= _amount;
    }
}