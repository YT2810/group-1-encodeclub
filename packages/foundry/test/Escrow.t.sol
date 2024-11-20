// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../contracts/Escrow.sol";

contract MultiEscrowTest is Test {
    MultiEscrow escrow;

    address payer;
    address payee;
    address arbiter;

    function setUp() public {
        payer = address(0x1); // Mock payer address
        payee = address(0x2); // Mock payee address
        arbiter = address(0x3); // Mock arbiter address

        vm.deal(payer, 10 ether); // Assign initial funds to the payer
        escrow = new MultiEscrow();
    }

    function testCreateEscrow() public {
        uint256 amount = 1 ether;
        uint256 escrowId = escrow.createEscrow(payee, arbiter, amount);

        (
            address retrievedPayer,
            address retrievedPayee,
            address retrievedArbiter,
            uint256 retrievedAmount,
            State retrievedState
        ) = escrow.escrows(escrowId);

        assertEq(retrievedPayer, address(this), "Payer address mismatch");
        assertEq(retrievedPayee, payee, "Payee address mismatch");
        assertEq(retrievedArbiter, arbiter, "Arbiter address mismatch");
        assertEq(retrievedAmount, amount, "Escrow amount mismatch");
        assertEq(uint256(retrievedState), uint256(State.AWAITING_PAYMENT), "Initial state mismatch");
    }

    function testDeposit() public {
        // Define the amount and create an escrow
        uint256 amount = 1 ether;
        vm.prank(payer); // Simulate the payer's transaction
        uint256 escrowId = escrow.createEscrow(payee, arbiter, amount);

        // Simulate the payer depositing funds
        vm.expectEmit(true, true, true, true);
        emit MultiEscrow.FundDeposited(escrowId, payer, amount); // Expected event with full qualifier
        vm.prank(payer); // Ensure the caller matches the `payer`
        escrow.deposit{value: amount}(escrowId);

        // Validate the updated state
        (
            , , , uint256 retrievedAmount, State retrievedState
        ) = escrow.escrows(escrowId);

        assertEq(retrievedAmount, amount, "Escrow amount mismatch after deposit");
        assertEq(uint256(retrievedState), uint256(State.AWAITING_DELIVERY), "State mismatch after deposit");
    }



}
