// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "../BeetsToReaper.sol";
import "../mocks/reaper/MockCrypt.sol";
import "solidity-mocks/beethoven/MockBeetsBar.sol";
import "solidity-mocks/balancer/MockBalancerVault.sol";
import "solidity-mocks/MockERC20.sol";

contract BeetsToReaperTest is DSTest {
  BeetsToReaper subject;
  MockCrypt crypt;
  MockBeetsBar beetsBar;
  MockBalancerVault balancerVault;
  MockERC20 beets;
  MockERC20 wftm;
  MockERC20 fBeetsBPT;
  bytes32 fBeetsPoolID;

  function setUp() public {

  }

  function testExample() public {
      assertTrue(true);
  }
}
