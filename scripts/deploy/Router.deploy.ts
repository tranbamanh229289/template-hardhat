import { ethers } from "hardhat";
import "dotenv/config";
import { Router } from "../../typechain-types";

async function main() {
  const contract: Router = await ethers.deployContract("Router", []);
  console.log("Start deploying Router...");
  await contract.waitForDeployment();
  console.log("Router deployed to", contract.target);
}

main().catch((err) => {
  console.log(err);
  process.exitCode = 1;
});
