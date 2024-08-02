import { ethers } from "hardhat";
import "dotenv/config";
import { AssetManager } from "../../typechain-types";

async function main() {
  const contract: AssetManager = await ethers.deployContract(
    "AssetManager",
    []
  );
  console.log("Start deploying AssetManager...");
  await contract.waitForDeployment();
  console.log("AssetManager deployed to", contract.target);
}

main().catch((err) => {
  console.log(err);
  process.exitCode = 1;
});
