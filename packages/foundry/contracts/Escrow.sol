//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Useful for debugging. Remove when deploying to a live network.
import "forge-std/console.sol";

// Use openzeppelin to inherit battle-tested implementations (ERC20, ERC721, etc)
// import "@openzeppelin/contracts/access/Ownable.sol";


enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, REFUNDED }

contract MultiEscrow {

    struct Escrow {
        address payer;
        address payee;
        address arbiter;
        uint256 amount;
        State currentState;
    }

    enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, REFUNDED }

    mapping(uint256 => Escrow) public escrows;
    uint256 public escrowCount;

    event FundDeposited(uint256 indexed escrowId, address indexed payer, uint256 amount);
    event FundReleased(uint256 indexed escrowId, address indexed payee, uint256 amount);
    event FundRefunded(uint256 indexed escrowId, address indexed payer, uint256 amount);

    error PayerPermissionRequired();
    error ArbiterPermissionRequired();
    error InvalidState(State expected, State current);
    error IncorrectDepositAmount(uint256 expected, uint256 actual);

    modifier onlyPayer(uint256 escrowId) {
        require(msg.sender == escrows[escrowId].payer, PayerPermissionRequired);
        _;
    }

    modifier onlyArbiter(uint256 escrowId) {
        require(msg.sender == escrows[escrowId].arbiter, ArbiterPermissionRequired);
        _;
    }

    modifier inState(uint256 escrowId, State expectedState) {
        require(escrows[escrowId].currentState == expectedState, InvalidState(expectedState, escrows[escrowId].currentState));
        _;
    }

    function createEscrow(address _payee, address _arbiter, uint256 _amount) external returns (uint256) {
        escrowCount++;
        escrows[escrowCount] = Escrow({
            payer: msg.sender,
            payee: _payee,
            arbiter: _arbiter,
            amount: _amount,
            currentState: State.AWAITING_PAYMENT
        });
        return escrowCount;
    }

    function deposit(uint256 escrowId) external payable onlyPayer(escrowId) inState(escrowId, State.AWAITING_PAYMENT) {
        if (msg.value != escrows[escrowId].amount) {
            revert IncorrectDepositAmount(escrows[escrowId].amount, msg.value);
        }
        escrows[escrowId].currentState = State.AWAITING_DELIVERY;
        emit FundDeposited(escrowId, msg.sender, msg.value);
    }

    function releaseFunds(uint256 escrowId) external onlyArbiter(escrowId) inState(escrowId, State.AWAITING_DELIVERY) {
        escrows[escrowId].currentState = State.COMPLETE;
        payable(escrows[escrowId].payee).transfer(escrows[escrowId].amount);
        emit FundReleased(escrowId, escrows[escrowId].payee, escrows[escrowId].amount);
    }

    function refund(uint256 escrowId) external onlyArbiter(escrowId) inState(escrowId, State.AWAITING_DELIVERY) {
        escrows[escrowId].currentState = State.REFUNDED;
        payable(escrows[escrowId].payer).transfer(escrows[escrowId].amount);
        emit FundRefunded(escrowId, escrows[escrowId].payer, escrows[escrowId].amount);
    }
}