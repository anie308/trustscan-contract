


const { ethers } = require("hardhat");
const { formatEther } = require("ethers/utils"); // ✅ add this import

async function main() {
  console.log("Deploying ProductAuthentication...");

  const [deployer] = await ethers.getSigners();
  console.log("Deployer address:", deployer.address);

  // ✅ Get balance properly
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Deployer balance:", formatEther(balance));

  const ProductAuth = await ethers.getContractFactory("ProductAuthentication");
  const productAuth = await ProductAuth.deploy();

  await productAuth.deployed();
  console.log("ProductAuthentication deployed to:", productAuth.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

