const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying VEGA Bio-PoS Smart Contract...");
  
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  
  const balance = await deployer.getBalance();
  console.log("Account balance:", ethers.utils.formatEther(balance), "ETH");
  
  // Deploy the contract
  const VEGABioPoS = await ethers.getContractFactory("VEGABioPoS");
  const vegaBioPoS = await VEGABioPoS.deploy();
  
  await vegaBioPoS.deployed();
  
  console.log("VEGA Bio-PoS deployed to:", vegaBioPoS.address);
  console.log("Transaction hash:", vegaBioPoS.deployTransaction.hash);
  
  // Verify deployment
  const code = await ethers.provider.getCode(vegaBioPoS.address);
  if (code === "0x") {
    console.error("Contract deployment failed!");
    process.exit(1);
  }
  
  console.log("✓ Contract deployed successfully!");
  
  // Save deployment info
  const deploymentInfo = {
    contractAddress: vegaBioPoS.address,
    deployerAddress: deployer.address,
    transactionHash: vegaBioPoS.deployTransaction.hash,
    blockNumber: vegaBioPoS.deployTransaction.blockNumber,
    gasUsed: vegaBioPoS.deployTransaction.gasLimit.toString(),
    timestamp: new Date().toISOString()
  };
  
  console.log("Deployment Info:", JSON.stringify(deploymentInfo, null, 2));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment failed:", error);
    process.exit(1);
  });