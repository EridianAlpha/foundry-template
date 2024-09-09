// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// ================================================================
// │                           IMPORTS                            │
// ================================================================

// Forge and Script Imports
import {console} from "lib/forge-std/src/Script.sol";
import {GetDeployedContract} from "script/GetDeployedContract.s.sol";

// Contract Imports
import {SimpleSwap} from "src/SimpleSwap.sol";
import {ForceSendEth} from "../test/testHelperContracts/ForceSendEth.sol";

// Library Directive Imports
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

// Interface Imports
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Import Modules
import {TokenSwapCalcsModule} from "src/modules/TokenSwapCalcsModule.sol";

// ================================================================
// │                         INTERACTIONS                         │
// ================================================================
contract Interactions is GetDeployedContract {
    function test() public override {} // Added to remove this whole contract from coverage report.

    // Library directives
    using Address for address payable;

    // Contract variables
    SimpleSwap public simpleSwap;

    function interactionsSetup() public {
        simpleSwap = SimpleSwap(payable(getDeployedContract("ERC1967Proxy")));
    }

    // ================================================================
    // │                         FORCE SEND ETH                       │
    // ================================================================
    function forceSendEth(uint256 _value) public {
        interactionsSetup();
        vm.startBroadcast();
        new ForceSendEth{value: _value}(payable(address(simpleSwap)));
        vm.stopBroadcast();
    }

    // ================================================================
    // │                         SWAP FUNCTIONS                       │
    // ================================================================
    function sendEth(uint256 _value) public {
        interactionsSetup();
        vm.startBroadcast();
        uint256 UsdcBalanceBefore = IERC20(simpleSwap.getTokenAddress("USDC")).balanceOf(address(msg.sender));
        payable(address(simpleSwap)).sendValue(_value);
        uint256 UsdcBalanceAfter = IERC20(simpleSwap.getTokenAddress("USDC")).balanceOf(address(msg.sender));
        console.log("ETH Swapped:   ", _value);
        console.log("USDC Received: ", UsdcBalanceAfter - UsdcBalanceBefore);
        vm.stopBroadcast();
    }

    function swapUsdc(uint256 _value) public {
        interactionsSetup();
        vm.startBroadcast();
        uint256 EthBalanceBefore = address(msg.sender).balance;
        IERC20(simpleSwap.getTokenAddress("USDC")).approve(address(simpleSwap), _value);
        simpleSwap.swapUsdc(_value);
        uint256 EthBalanceAfter = address(msg.sender).balance;
        console.log("USDC Swapped: ", _value);
        console.log("ETH Received: ", EthBalanceAfter - EthBalanceBefore);
        vm.stopBroadcast();
    }

    // ================================================================
    // │                       WITHDRAW FUNCTIONS                     │
    // ================================================================
    function withdrawEth(address _owner) public {
        interactionsSetup();
        vm.startBroadcast();
        simpleSwap.withdrawEth(_owner);
        vm.stopBroadcast();
    }

    function withdrawTokens(string memory _identifier, address _owner) public {
        interactionsSetup();
        vm.startBroadcast();
        simpleSwap.withdrawTokens(_identifier, _owner);
        vm.stopBroadcast();
    }

    // ================================================================
    // │                            UPGRADES                          │
    // ================================================================
    function upgrade() public {
        interactionsSetup();
        vm.startBroadcast();
        // Deploy new implementation contract
        SimpleSwap newSimpleSwapImplementation = new SimpleSwap();

        // Upgrade to new implementation contract
        simpleSwap.upgradeToAndCall(address(newSimpleSwapImplementation), "");

        // Deploy new modules
        simpleSwap.updateContractAddress("tokenSwapCalcsModule", address(new TokenSwapCalcsModule()));

        vm.stopBroadcast();
    }

    // ================================================================
    // │                            UPDATES                           │
    // ================================================================
    function updateContractAddress(string memory _identifier, address _newContractAddress) public {
        interactionsSetup();
        vm.startBroadcast();
        simpleSwap.updateContractAddress(_identifier, _newContractAddress);
        vm.stopBroadcast();
    }

    function updateTokenAddress(string memory _identifier, address _newContractAddress) public {
        interactionsSetup();
        vm.startBroadcast();
        simpleSwap.updateTokenAddress(_identifier, _newContractAddress);
        vm.stopBroadcast();
    }

    function updateUniswapV3PoolAddress(string memory _identifier, address _newContractAddress, uint24 _newFee)
        public
    {
        interactionsSetup();
        vm.startBroadcast();
        simpleSwap.updateUniswapV3Pool(_identifier, _newContractAddress, _newFee);
        vm.stopBroadcast();
    }

    function updateSlippageTolerance(uint16 _value) public {
        interactionsSetup();
        vm.startBroadcast();
        simpleSwap.updateSlippageTolerance(_value);
        vm.stopBroadcast();
    }

    // ================================================================
    // │                         ROLE MANAGEMENT                       │
    // ================================================================
    function grantRole(string memory _roleString, address _account) public {
        interactionsSetup();
        vm.startBroadcast();
        simpleSwap.grantRole(keccak256(abi.encodePacked(_roleString)), _account);
        vm.stopBroadcast();
    }

    function revokeRole(string memory _roleString, address _account) public {
        interactionsSetup();
        vm.startBroadcast();
        simpleSwap.revokeRole(keccak256(abi.encodePacked(_roleString)), _account);
        vm.stopBroadcast();
    }

    function getRoleAdmin(string memory _roleString) public returns (bytes32 roleAdmin) {
        vm.startBroadcast();
        interactionsSetup();
        roleAdmin = simpleSwap.getRoleAdmin(keccak256(abi.encodePacked(_roleString)));
        vm.stopBroadcast();
    }

    function getRoleMember(string memory _roleString, uint256 _index) public returns (address roleMember) {
        vm.startBroadcast();
        interactionsSetup();
        roleMember = simpleSwap.getRoleMember(keccak256(abi.encodePacked(_roleString)), _index);
        vm.stopBroadcast();
    }

    function getRoleMembers(string memory _roleString) public returns (address[] memory members) {
        vm.startBroadcast();
        interactionsSetup();
        members = simpleSwap.getRoleMembers(_roleString);
        vm.stopBroadcast();
    }

    function getRoleMemberCount(string memory _roleString) public returns (uint256 memberCount) {
        vm.startBroadcast();
        interactionsSetup();
        memberCount = simpleSwap.getRoleMemberCount(keccak256(abi.encodePacked(_roleString)));
        vm.stopBroadcast();
    }

    function checkRole(string memory _roleString, address _account) public returns (bool hasRole) {
        vm.startBroadcast();
        interactionsSetup();
        hasRole = simpleSwap.hasRole(keccak256(abi.encodePacked(_roleString)), _account);
        vm.stopBroadcast();
    }

    function renounceRole(string memory _roleString) public {
        interactionsSetup();
        vm.startBroadcast();
        // Prove the msg.sender as confirmation to renounce the role
        simpleSwap.renounceRole(keccak256(abi.encodePacked(_roleString)), msg.sender);
        vm.stopBroadcast();
    }

    // ================================================================
    // │                            GETTERS                           │
    // ================================================================
    function getCreator() public returns (address creator) {
        vm.startBroadcast();
        interactionsSetup();
        creator = simpleSwap.getCreator();
        vm.stopBroadcast();
    }

    function getVersion() public returns (string memory version) {
        vm.startBroadcast();
        interactionsSetup();
        version = simpleSwap.getVersion();
        vm.stopBroadcast();
    }

    function getBalance(string memory _identifier) public returns (uint256 balance) {
        vm.startBroadcast();
        interactionsSetup();
        balance = simpleSwap.getBalance(_identifier);
        vm.stopBroadcast();
    }

    function getEventBlockNumbers() public returns (uint64[] memory eventBlockNumbers) {
        vm.startBroadcast();
        interactionsSetup();
        eventBlockNumbers = simpleSwap.getEventBlockNumbers();
        vm.stopBroadcast();
    }

    function getContractAddress(string memory _identifier) public returns (address contractAddress) {
        vm.startBroadcast();
        interactionsSetup();
        contractAddress = simpleSwap.getContractAddress(_identifier);
        vm.stopBroadcast();
    }

    function getTokenAddress(string memory _identifier) public returns (address tokenAddress) {
        vm.startBroadcast();
        interactionsSetup();
        tokenAddress = simpleSwap.getTokenAddress(_identifier);
        vm.stopBroadcast();
    }

    function getUniswapV3Pool(string memory _identifier)
        public
        returns (address uniswapV3PoolAddress, uint24 uniswapV3PoolFee)
    {
        vm.startBroadcast();
        interactionsSetup();
        (uniswapV3PoolAddress, uniswapV3PoolFee) = simpleSwap.getUniswapV3Pool(_identifier);
        vm.stopBroadcast();
    }

    function getSlippageTolerance() public returns (uint256 slippageTolerance) {
        vm.startBroadcast();
        interactionsSetup();
        slippageTolerance = simpleSwap.getSlippageTolerance();
        vm.stopBroadcast();
    }

    function getModuleVersion(string memory _identifier) public returns (string memory moduleVersion) {
        vm.startBroadcast();
        interactionsSetup();
        address moduleAddress = simpleSwap.getContractAddress(_identifier);

        (bool success, bytes memory data) = moduleAddress.call(abi.encodeWithSignature("VERSION()"));

        if (success) {
            moduleVersion = abi.decode(data, (string));
        }

        vm.stopBroadcast();
    }
}
