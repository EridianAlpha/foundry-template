// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract ForceSendEth {
    function test() public {} // Added to remove this whole testing file from coverage report.

    constructor(address payable _to) payable {
        selfdestruct(_to);
    }
}
