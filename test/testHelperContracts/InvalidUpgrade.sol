// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/// @notice This contract is used to test UUPS upgrade to an invalid contract.
/// @dev The contact is not a valid upgradeable contract so the upgrade should fail.
contract InvalidUpgrade {
    function test() public {} // Added to remove this whole testing file from coverage report.

    string private constant VERSION = "INVALID_UPGRADE_VERSION";

    function getVersion() public pure returns (string memory) {
        return VERSION;
    }
}
