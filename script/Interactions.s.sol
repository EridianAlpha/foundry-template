// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "@foundry-devops/src/DevOpsTools.sol";

import {AavePM} from "src/AavePM.sol";

// ================================================================
// │                             SETUP                            │
// ================================================================
contract Interactions is Script {
    AavePM public aavePM;

    function interactionsSetup() public {
        address _proxyAddress;

        // If an address is provided in the .env, use it. Otherwise, get the most recent deployment.
        try vm.envAddress("DEPLOYED_CONTRACT_ADDRESS") returns (address addr) {
            if (addr != address(0)) {
                _proxyAddress = addr;
            } else {
                _proxyAddress = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);
            }
        } catch {
            _proxyAddress = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);
        }

        require(_proxyAddress != address(0), "ERC1967Proxy address is invalid");
        aavePM = AavePM(payable(_proxyAddress));
    }

    // ================================================================
    // │                             FUND                             │
    // ================================================================
    function fundAavePM(uint256 value) public {
        interactionsSetup();
        vm.startBroadcast();
        (bool callSuccess,) = address(aavePM).call{value: value}("");
        if (!callSuccess) revert("Failed to send ETH to AavePM");
        vm.stopBroadcast();
    }

    // ================================================================
    // │                  FUNCTIONS - ROLE MANAGEMENT                 │
    // ================================================================
    function grantRoleAavePM(string memory roleString, address account) public {
        bytes32 roleBytes = keccak256(abi.encodePacked(roleString));
        interactionsSetup();
        vm.startBroadcast();
        aavePM.grantRole(roleBytes, account);
        vm.stopBroadcast();
    }

    function revokeRoleAavePM(string memory roleString, address account) public {
        bytes32 roleBytes = keccak256(abi.encodePacked(roleString));
        interactionsSetup();
        vm.startBroadcast();
        aavePM.revokeRole(roleBytes, account);
        vm.stopBroadcast();
    }