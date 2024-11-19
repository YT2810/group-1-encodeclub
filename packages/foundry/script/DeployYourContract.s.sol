//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/Escrow.sol";
import "./DeployHelpers.s.sol";

contract DeployYourContract is ScaffoldETHDeploy {
  // use `deployer` from `ScaffoldETHDeploy`
  function run() external ScaffoldEthDeployerRunner {
    Escrow escrowContract = new Escrow();
    console.logString(
      string.concat(
        "Escrow deployed at: ", vm.toString(address(escrowContract))
      )
    );
  }
}
