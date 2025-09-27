// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ManufacturerRegistry
 * @dev Handles regulator authority and manufacturer approvals.
 */
contract ManufacturerRegistry is Ownable {
    address public regulator;
    mapping(address => bool) public approvedManufacturers;

    event ManufacturerApproved(address indexed manufacturer);
    event ManufacturerRevoked(address indexed manufacturer);

    modifier onlyRegulator() {
        require(msg.sender == regulator, "Only regulator");
        _;
    }

    constructor(address _regulator) Ownable(_regulator) {
        regulator = _regulator;
    }

    function approveManufacturer(address manufacturer) external onlyRegulator {
        require(manufacturer != address(0), "Invalid manufacturer");
        require(!approvedManufacturers[manufacturer], "Already approved");

        approvedManufacturers[manufacturer] = true;
        emit ManufacturerApproved(manufacturer);
    }

    function revokeManufacturer(address manufacturer) external onlyRegulator {
        require(approvedManufacturers[manufacturer], "Not approved");

        approvedManufacturers[manufacturer] = false;
        emit ManufacturerRevoked(manufacturer);
    }

    function isManufacturerApproved(address manufacturer) external view returns (bool) {
        return approvedManufacturers[manufacturer];
    }
}
