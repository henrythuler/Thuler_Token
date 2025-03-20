// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "@lib/forge/src/Test.sol";
import "../src/Thuler.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface CheatCodes {
    function startPrank(address) external; //Setting msg.sender (Transaction Sender)

    function stopPrank() external; //Stopping execution

    function expectRevert() external; //When an Exception is expected
}

contract ThulerTest is Test {
    Thuler private thr; // Contract Instance
    CheatCodes cheats = CheatCodes(VM_ADDRESS); //Simulating our VM

    address defaultOwner = address(1);
    address notAuthorizedMinter = address(3);
    uint256 initialSupply = 1000 * 1e18; //Tokens Units * Token Decimals

    function setUp() public {
        cheats.startPrank(defaultOwner);
        thr = new Thuler(defaultOwner, initialSupply);
        cheats.stopPrank();
    }

    function testSetUp() public view {
        assertEq(thr.owner(), defaultOwner, "It should be 1.");
        assertEq(thr.totalSupply(), initialSupply, "It should be 1000 * 1e18");
    }

    function testMint() public {
        uint256 mintAmount = 500 * 1e18;
        address recipient = address(99);
        uint256 supply = thr.totalSupply();

        cheats.startPrank(defaultOwner);
        thr.mint(recipient, mintAmount);
        cheats.stopPrank();

        assertEq(
            thr.balanceOf(recipient),
            mintAmount,
            "It should be equal to mint amount (500 * 1e18)"
        );

        assertEq(
            thr.totalSupply(),
            (supply + mintAmount),
            "It should be equal to totalSupply + mintAmount"
        );
    }

    function testBurn() public {
        uint256 burnAmount = 100 * 1e18;
        uint256 oldBalance = thr.balanceOf(defaultOwner);
        uint256 oldSupply = thr.totalSupply();

        cheats.startPrank(defaultOwner);
        thr.burn(defaultOwner, burnAmount);
        cheats.stopPrank();

        assertEq(thr.balanceOf(defaultOwner), oldBalance - burnAmount);
        assertEq(
            thr.totalSupply(),
            oldSupply - burnAmount,
            "It should be old supply - burn amount"
        );
    }

    function testTransfer() public {
        uint256 transferValue = 100 * 1e18;
        address recipient = address(99);
        uint256 recipientOldBalance = thr.balanceOf(recipient);

        uint256 senderOldBalance = thr.balanceOf(defaultOwner);

        cheats.startPrank(defaultOwner);
        thr.transfer(recipient, transferValue);
        cheats.stopPrank();

        uint256 recipientNewBalance = thr.balanceOf(recipient);
        uint256 senderNewBalance = thr.balanceOf(defaultOwner);

        assertEq(
            recipientNewBalance,
            recipientOldBalance + transferValue,
            "It should be old balance + transfer value."
        );
        assertEq(
            senderNewBalance,
            senderOldBalance - transferValue,
            "It should be olg balance - transfer value"
        );
    }
}
