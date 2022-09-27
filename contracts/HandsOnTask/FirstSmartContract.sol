// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract MySmartContract {
    address public owner;
    uint256 public balance;

    constructor() {
        owner = msg.sender;
    }

    receive() payable external {
        balance += msg.value
    }

    function withdraw(uint amount, address payable receiver) public {

        require(owner==msg.sender, "Only owner can withdraw");
        require(balance<=amount, "Not enough balance for the transaction")
        receiver.transfer(amount);
        balance -= amount;
    }
}