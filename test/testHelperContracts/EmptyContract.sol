// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/// @notice This contract is used to test the .call functions failing.
/// @dev This contract causes the .call to fail as it doesn't have a receive()
///      or fallback() function so the ETH can't be accepted.
contract EmptyContract {}
