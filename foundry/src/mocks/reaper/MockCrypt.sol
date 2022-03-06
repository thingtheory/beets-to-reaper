// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../../interfaces/reaper/ICrypt.sol";
import "solidity-mocks/MockERC20.sol";

contract MockCrypt is ICrypt, MockERC20 {
  constructor() MockERC20("MockCrypt", "MC") {}

  function deposit(uint256 amount) external override {}
}
