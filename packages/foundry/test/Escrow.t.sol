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
        vm.deal(payee, 0 ether); // Initialize payee's balance
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

    function testReleaseFunds() public {
        // Define the amount and create an escrow
        uint256 amount = 1 ether;
        vm.prank(payer); // Simulate the payer's transaction
        uint256 escrowId = escrow.createEscrow(payee, arbiter, amount);

        // Deposit funds to the escrow
        vm.prank(payer);
        escrow.deposit{value: amount}(escrowId);

        // Simulate the arbiter releasing funds
        vm.expectEmit(true, true, true, true);
        emit MultiEscrow.FundReleased(escrowId, payee, amount); // Expected event with full qualifier
        vm.prank(arbiter); // Ensure the caller matches the `arbiter`
        escrow.releaseFunds(escrowId);

        // Validate the updated state
        (
            , , , , State retrievedState
        ) = escrow.escrows(escrowId);

        assertEq(uint256(retrievedState), uint256(State.COMPLETE), "State mismatch after releasing funds");

        // Validate that the payee received the funds
        assertEq(payee.balance, amount, "Payee did not receive the correct amount");
    }

    function testRefundOptimized() public {
        // Define the amount and create an escrow
        uint256 amount = 1 ether;
        vm.prank(payer); // Simulate the payer's transaction
        uint256 escrowId = escrow.createEscrow(payee, arbiter, amount);

        // Simulate the payer depositing funds into the escrow
        vm.prank(payer);
        escrow.deposit{value: amount}(escrowId);

        // Expect the FundRefunded event with the correct parameters
        vm.expectEmit(true, true, true, true);
        emit MultiEscrow.FundRefunded(escrowId, payer, amount);

        // Simulate the arbiter calling the refund function
        vm.prank(arbiter);
        escrow.refund(escrowId);

        // Validate the updated state of the escrow
        (
            , , , uint256 retrievedAmount, State retrievedState
        ) = escrow.escrows(escrowId);

        // Assert the state has changed to REFUNDED
        assertEq(uint256(retrievedState), uint256(State.REFUNDED), "State mismatch after refund");

        // Assert the amount is still correct in the escrow record
        assertEq(retrievedAmount, amount, "Escrow amount mismatch after refund");

        // Assert the payer's balance has increased by the refunded amount
        assertEq(payer.balance, 10 ether, "Payer did not receive the correct amount after refund");
    }

    function testDepositFromNonPayer() public {
        uint256 amount = 1 ether;
        vm.prank(payer); // Simula la transacción desde el `payer`
        uint256 escrowId = escrow.createEscrow(payee, arbiter, amount);

        // Simula un intento de depósito por parte de un usuario no autorizado
        vm.prank(payee); 
        vm.expectRevert("Payer Permission Required"); // Mensaje literal esperado
        escrow.deposit{value: amount}(escrowId);
    }


    function testReleaseFundsFromNonArbiter() public {
        uint256 amount = 1 ether;
        vm.prank(payer);
        uint256 escrowId = escrow.createEscrow(payee, arbiter, amount);
        vm.prank(payer);
        escrow.deposit{value: amount}(escrowId);

        // Simulate a non-arbiter trying to release funds
        vm.prank(payee); 
        vm.expectRevert("Arbiter Permission Required");
        escrow.releaseFunds(escrowId);
    }

}


