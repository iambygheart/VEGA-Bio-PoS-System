const hre = require("hardhat");
const { verifyDeployment } = require("./verify");

async function main() {
  console.log("🚀 Deploying VEGA Bio-PoS to", hre.network.name);
  console.log("=" * 40);
  
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deployer:", deployer.address);
  
  const balance = await deployer.getBalance();
  console.log("Balance:", hre.ethers.utils.formatEther(balance), "ETH");
  
  if (balance.lt(hre.ethers.utils.parseEther("0.01"))) {
    throw new Error("Insufficient balance for deployment");
  }
  
  console.log("\n📋 Deploying contract...");
  const VEGABioPoS = await hre.ethers.getContractFactory("VEGABioPoS");
  const vegaBioPoS = await VEGABioPoS.deploy();
  
  console.log("⏳ Waiting for deployment...");
  await vegaBioPoS.deployed();
  
  console.log("\n✅ DEPLOYMENT SUCCESSFUL!");
  console.log("Contract Address:", vegaBioPoS.address);
  console.log("Transaction Hash:", vegaBioPoS.deployTransaction.hash);
  console.log("Block Number:", vegaBioPoS.deployTransaction.blockNumber);
  
  // Verify deployment
  const verified = await verifyDeployment(vegaBioPoS.address);
  
  // Save deployment info
  const deploymentInfo = {
    network: hre.network.name,
    chainId: hre.network.config.chainId,
    contractAddress: vegaBioPoS.address,
    deployerAddress: deployer.address,
    transactionHash: vegaBioPoS.deployTransaction.hash,
    blockNumber: vegaBioPoS.deployTransaction.blockNumber,
    gasUsed: vegaBioPoS.deployTransaction.gasLimit?.toString(),
    timestamp: new Date().toISOString(),
    verified: verified
  };
  
  const fs = require('fs');
  fs.writeFileSync(
    `deployment-${hre.network.name}.json`, 
    JSON.stringify(deploymentInfo, null, 2)
  );
  
  console.log(`\n📄 Deployment info saved to deployment-${hre.network.name}.json`);
  console.log("🎉 Deployment completed successfully!");
  
  return deploymentInfo;
}

if (require.main === module) {
  main().catch((error) => {
    console.error("Deployment failed:", error);
    process.exit(1);
  });
}

module.exports = main;