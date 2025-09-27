// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./ManufacturerRegistry.sol";
import "./ProductRegistry.sol";

/**
 * @title ProductAuthentication
 * @dev High-level controller linking manufacturer and product registries.
 */
contract ProductAuthentication {
    ManufacturerRegistry public manufacturerRegistry;
    ProductRegistry public productRegistry;

    constructor() {
        manufacturerRegistry = new ManufacturerRegistry(msg.sender);
        productRegistry = new ProductRegistry(address(manufacturerRegistry));
    }

    function getManufacturerRegistry() external view returns (address) {
        return address(manufacturerRegistry);
    }

    function getProductRegistry() external view returns (address) {
        return address(productRegistry);
    }
}
