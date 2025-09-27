// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title ProductRegistry
 * @dev Handles product registration, recall, and verification.
 */
contract ProductRegistry is ReentrancyGuard {
    struct Product {
        uint256 productId;
        address manufacturer;
        string name;
        string batchNumber;
        string expiryDate;
        string qrCodeHash;
        string metadataURI;
        bool active;
        uint256 timestamp;
    }

    mapping(uint256 => Product) public products;
    mapping(string => bool) private usedQrHashes;
    uint256 public productCounter;

    address public manufacturerRegistry;

    event ProductRegistered(uint256 indexed productId, address indexed manufacturer);
    event ProductRecalled(uint256 indexed productId);
    event ProductVerified(uint256 indexed productId, address indexed consumer, bool valid);

    modifier onlyManufacturer(address manufacturer) {
        // External check: ask ManufacturerRegistry via low-level call
        (bool success, bytes memory result) = manufacturerRegistry.staticcall(
            abi.encodeWithSignature("isManufacturerApproved(address)", manufacturer)
        );
        require(success && abi.decode(result, (bool)), "Not approved manufacturer");
        _;
    }

    constructor(address _manufacturerRegistry) {
        manufacturerRegistry = _manufacturerRegistry;
    }

    function registerProduct(
        string memory name,
        string memory batchNumber,
        string memory expiryDate,
        string memory qrCodeHash,
        string memory metadataURI
    ) external onlyManufacturer(msg.sender) nonReentrant {
        require(bytes(name).length > 0, "Empty name");
        require(bytes(batchNumber).length > 0, "Empty batch");
        require(bytes(expiryDate).length > 0, "Empty expiry");
        require(bytes(qrCodeHash).length > 0, "Empty QR hash");
        require(!usedQrHashes[qrCodeHash], "QR already used");

        productCounter++;
        uint256 newId = productCounter;

        products[newId] = Product({
            productId: newId,
            manufacturer: msg.sender,
            name: name,
            batchNumber: batchNumber,
            expiryDate: expiryDate,
            qrCodeHash: qrCodeHash,
            metadataURI: metadataURI,
            active: true,
            timestamp: block.timestamp
        });

        usedQrHashes[qrCodeHash] = true;
        emit ProductRegistered(newId, msg.sender);
    }

    function recallProduct(uint256 productId) external {
        require(productId > 0 && productId <= productCounter, "Invalid ID");
        Product storage product = products[productId];
        require(product.manufacturer == msg.sender, "Not manufacturer");
        require(product.active, "Already inactive");

        product.active = false;
        emit ProductRecalled(productId);
    }

    function verifyProduct(
        uint256 productId,
        string memory qrCodeHash
    ) external returns (bool valid, Product memory product) {
        require(productId > 0 && productId <= productCounter, "Invalid ID");

        product = products[productId];
        valid = (
            product.active &&
            keccak256(abi.encodePacked(product.qrCodeHash)) == keccak256(abi.encodePacked(qrCodeHash))
        );

        emit ProductVerified(productId, msg.sender, valid);
        return (valid, product);
    }

    function getProduct(uint256 productId) external view returns (Product memory) {
        require(productId > 0 && productId <= productCounter, "Invalid ID");
        return products[productId];
    }

    function getTotalProducts() external view returns (uint256) {
        return productCounter;
    }
}
