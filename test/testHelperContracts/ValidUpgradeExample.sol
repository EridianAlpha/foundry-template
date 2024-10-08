// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @notice This contract is an example of an upgradeable contract using the UUPS pattern.
contract SimpleSwapUpgradeExample is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    function test() public {} // Added to remove this whole testing file from coverage report.

    bytes32 private constant OWNER_ROLE = keccak256("OWNER_ROLE");
    string private constant VERSION = "9.9.9";

    // ================================================================
    // │                   FUNCTIONS - UUPS UPGRADES                  │
    // ================================================================
    /// @notice Internal function to authorize an upgrade.
    /// @dev Only callable by the owner role.
    /// @param _newImplementation Address of the new contract implementation.
    function _authorizeUpgrade(address _newImplementation) internal override onlyRole(OWNER_ROLE) {}

    function getVersion() public pure returns (string memory) {
        return VERSION;
    }
}
