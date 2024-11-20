// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../contracts/Escrow.sol";

contract MultiEscrowTest is Test {
    MultiEscrow escrow;

    address deployer;
    address payee;
    address arbiter;

    function setUp() public {
        deployer = address(this); // The address of the test contract
        payee = address(0x2);     // Mock payee address
        arbiter = address(0x3);   // Mock arbiter address
        escrow = new MultiEscrow(); // Deploy the MultiEscrow contract
    }

    function testCreateEscrow() public {
        uint256 amount = 1 ether;
        uint256 escrowId = escrow.createEscrow(payee, arbiter, amount);

        // Unpack the tuple returned by the `escrows` mapping
        (
            address payer,
            address retrievedPayee,
            address retrievedArbiter,
            uint256 retrievedAmount,
            State retrievedState
        ) = escrow.escrows(escrowId);

        // Validate the retrieved values
        assertEq(payer, deployer, "Payer address mismatch");
        assertEq(retrievedPayee, payee, "Payee address mismatch");
        assertEq(retrievedArbiter, arbiter, "Arbiter address mismatch");
        assertEq(retrievedAmount, amount, "Escrow amount mismatch");
        assertEq(uint256(retrievedState), uint256(State.AWAITING_PAYMENT), "Initial state mismatch");
    }
}
