import { ethers } from "hardhat";
import "dotenv/config";
import { Factory } from "../../typechain-types";

async function main() {
  const contract: Factory = await ethers.deployContract("Factory", []);
  console.log("Start deploying Factory...");
  await contract.waitForDeployment();
  console.log("Factory deployed to", contract.target);
}

main().catch((err) => {
  console.log(err);
  process.exitCode = 1;
});
