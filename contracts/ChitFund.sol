// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

// import "./Ownable.sol";

contract ChitFund {
    address payable public owner;

    uint8 totalMembers = 3;
    uint8 currMemberCount = 0;
    uint256 chitFundDuration = 3;
    uint256 individualDepositAmount = 0.01 ether;
    uint256 surplus = 0.003 ether;
    uint256 collateralAmount = individualDepositAmount + surplus;

    struct person {
        bool isMember;
        uint256 loanGranted;
        uint256 lastDepositedTime;
    }

    struct stats {
        uint16 currPeriod;
        uint256 totalDeposits;
        uint256 lendingAmount;
    }

    stats trxnStats;

    mapping(address => person) public members;

    constructor() payable {
        owner = payable(msg.sender);
    }

    modifier canDeposit() {
        require(members[msg.sender].isMember == true);
        require(currMemberCount <= totalMembers);
        _;
    }

    modifier canWithDraw() {
        require(members[msg.sender].isMember == true);
        require(owner != payable(address(0)));
        require(currMemberCount == totalMembers);
        // require(trxnStats.currPeriod <= chitFundDuration);
        require(
            trxnStats.totalDeposits >= totalMembers * individualDepositAmount
        );
        _;
    }

    function deposit() public payable canDeposit {
        if (
            currMemberCount == totalMembers &&
            (!(members[msg.sender].isMember == true))
        ) {
            console.log("No place for more people!!!");
        } else {
            if (!(members[msg.sender].isMember == true)) {
                members[msg.sender] = person(true, 0, block.timestamp);
                console.log(
                    "before deposit currMemberCount: %s",
                    currMemberCount
                );
                currMemberCount++;
                console.log(
                    "after deposit currMemberCount: %s",
                    currMemberCount
                );
            }
            console.log(
                "before deposit trxnStats.totalDeposits: %s",
                trxnStats.totalDeposits
            );
            trxnStats.totalDeposits += msg.value;
            uint256 balance = address(this).balance;
            console.log("before balance: %s", balance);
            (bool success, ) = owner.call{value: msg.value}("");
            balance = address(this).balance;
            console.log("after balance: %s", balance);
            require(success, "Failed to deposit Ether to owner");
            console.log(
                "after deposit trxnStats.totalDeposits: %s",
                trxnStats.totalDeposits
            );
        }
    }

    function withdraw() public canWithDraw {
        uint256 amount = address(this).balance;
        console.log("before amount: %s", amount);
        console.log("collateralAmount: %s", collateralAmount);
        (bool success, ) = msg.sender.call{value: collateralAmount}("");
        require(success, "Failed to withdraw Ether from owner");
        amount = address(this).balance;
        console.log("after amount: %s", amount);
    }
}
