// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract ChitFund {
    address owner;
    uint256 previousBalance;

    event addedFunds(address whoAdded, uint256 howMuch);

    function ChitFund() {
        owner = msg.sender;
        members[owner] = member(true, true, 0, 0);
        previousBalance = this.balance;
    }

    struct member {
        bool isMember;
        bool isPermitted;
        uint256 loanGranted;
        int256 amountAddedToThePool;
    }

    mapping(address => member) members;
    mapping(address => uint256) loanGranted;

    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlymember() {
        require(members[msg.sender].isMember == true);
        _;
    }

    function addMembers(address _memberaddress) public {
        members[_memberaddress] = member(true, true, 0, 0);
    }

    function removeMembers(address _memberaddress) public {
        delete members[_memberaddress];
    }

    function addFundsorPayLoan() payable onlymember {
        // uint256 changeInBalance = this.balance - previousBalance;
        members[msg.sender].amountAddedToThePool += int256(msg.value);
        if (
            members[msg.sender].loanGranted > 0 &&
            members[msg.sender].loanGranted > msg.value
        ) {
            members[msg.sender].loanGranted -= msg.value;
        } else if (members[msg.sender].loanGranted <= msg.value) {
            members[msg.sender].isPermitted = true;
            members[msg.sender].loanGranted = 0;
        }
        addedFunds(msg.sender, msg.value);
        // previousBalance = this.balance;
    }

    function requestLoan(uint256 loanAmount) onlymember returns (bool status) {
        if (
            members[msg.sender].isPermitted &&
            int256(loanAmount) <=
            2 * members[msg.sender].amountAddedToThePool &&
            loanAmount <= this.balance / 2
        ) {
            members[msg.sender].isPermitted = false;
            members[msg.sender].loanGranted = loanAmount;
            members[msg.sender].amountAddedToThePool -= int256(loanAmount);
            msg.sender.transfer(loanAmount);
            // previousBalance = this.balance;
            return true;
        } else {
            revert();
        }
    }

    function getLoanGranted() constant returns (uint256) {
        return members[msg.sender].loanGranted;
    }

    function getBalance() constant returns (uint256) {
        return this.balance;
    }

    function getAmoundAdded() constant returns (int256) {
        return members[msg.sender].amountAddedToThePool;
    }
}
