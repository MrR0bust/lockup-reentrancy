// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
}

contract Lockup{
    IERC20 public token;
    address public beneficiary;
    uint256 public unlockTime;

    // 🔥 NEW: internal accounting (this is where bug lives)
    mapping(address => uint256) public balances;

    constructor(address _token, address _beneficiary, uint256 _unlockTime) {
        token = IERC20(_token);
        beneficiary = _beneficiary;
        unlockTime = _unlockTime;
    }

    // deposit tokens into lockup
    function deposit(uint256 amount) external {
        balances[msg.sender] += amount;
    }
 
    // 🔥 VULNERABLE WITHDRAW
    function withdraw() external {
        require(msg.sender == beneficiary, "not beneficiary");
        require(block.timestamp > unlockTime, "still locked");

        uint256 amount = balances[msg.sender];
        require(amount > 0, "nothing to withdraw");

        // ❌ INTERACTION FIRST (bug)
        token.transfer(msg.sender, amount);

        // ❌ EFFECT AFTER (bug)
        balances[msg.sender] = 0;
    }
}
