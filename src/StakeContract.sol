// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/console.sol";

error TransferFailed();

contract StakeContract {
    mapping(address => uint256) public s_balances;
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        // locked = false;
    }

    function stake(uint256 amount, address token) external returns (bool) {
        s_balances[msg.sender] += amount;
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);

        if (!success) revert TransferFailed();
        return success;
    }

    function claim(uint256 amount, address token) external {
        // // dapat wala to:
        // require(s_balances[msg.sender] >= amount, "ops");
        console.logString("entered, current balance: ");
        // console.logUint(s_balances[msg.sender]);
        console.logString("[before balance]");
        console.log(IERC20(token).balanceOf(address(this)));
        IERC20(token).approve(msg.sender, type(uint256).max);
        IERC20(token).transfer(msg.sender, amount);
        console.logString("[after balance]");
        console.log(IERC20(token).balanceOf(address(this)));
        console.log("[accounting balances...]");
        s_balances[msg.sender] -= amount;

        // if (!success) revert TransferFailed();

        // return success;
    }
}
