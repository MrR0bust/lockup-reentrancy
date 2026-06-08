// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract LockupPatched {
    IERC20 public immutable token;
    address public immutable beneficiary;
    uint256 public immutable unlockTime;

    mapping(address => uint256) public balances;

    bool private locked;

    constructor(
        address _token,
        address _beneficiary,
        uint256 _unlockTime
    ) {
        token = IERC20(_token);
        beneficiary = _beneficiary;
        unlockTime = _unlockTime;
    }

    modifier nonReentrant() {
        require(!locked, "reentrant call");

        locked = true;
        _;
        locked = false;
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "amount = 0");

        require(
            token.transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            "transfer failed"
        );

        balances[beneficiary] += amount;
    }

    function withdraw()
        external
        nonReentrant
    {
        require(
            msg.sender == beneficiary,
            "not beneficiary"
        );

        require(
            block.timestamp >= unlockTime,
            "still locked"
        );

        uint256 amount = balances[msg.sender];

        require(
            amount > 0,
            "nothing to withdraw"
        );

        /*
         * EFFECTS
         */
        balances[msg.sender] = 0;

        /*
         * INTERACTIONS
         */
        require(
            token.transfer(
                msg.sender,
                amount
            ),
            "transfer failed"
        );
    }
}
