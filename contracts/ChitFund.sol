// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

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

    stats public trxnStats;
    
    mapping(address => person) public members;

    constructor() payable {
        owner = payable(address(this));
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
    
    function deposit() public canDeposit payable {
        if (
            currMemberCount == totalMembers &&
            (members[msg.sender].isMember == false)
        ) {
            console.log("No place for more people!!!");
        } else {
            if (members[msg.sender].isMember == false) {
                members[msg.sender] = person(true, 0, block.timestamp);
                currMemberCount++;
            }
            trxnStats.totalDeposits += msg.value;
        }
    }
    
    function getAddress() public view returns (address) {
        return msg.sender;
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function withdraw() public canWithDraw {
        (bool success, ) = payable(msg.sender).call{value: collateralAmount}("");
        require(success, "Failed to withdraw Ether from contract");
        trxnStats.totalDeposits -= collateralAmount;
    }
}

