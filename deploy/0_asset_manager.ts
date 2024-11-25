import { DeployFunction, DeployResult } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { sleep } from "./utils";

import * as path from "path";

const deployConduitController: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { deployer } = await hre.getNamedAccounts();
  // deploy
  const resultDeploy: DeployResult = await hre.deployments.deploy(
    "AssetManager",
    {
      proxy: {
        proxyContract: "UUPS",
        execute: {
          init: {
            methodName: "initialize",
            args: [],
          },
        },
      },
      from: deployer,
      log: true,
      deterministicDeployment: false,
      gasPrice: "100000000000",
    }
  );

  // verify
  try {
    await hre.run("verify:verify", {
      address: resultDeploy.implementation,
      contract: "contracts/AssetManager.sol:AssetManager",
      constructorArguments: [],
    });
  } catch (err) {
    console.log(err);
  }
  console.log("impl: ", resultDeploy.implementation);
  console.log("proxy:", resultDeploy.address);
  await sleep(500);
};

deployConduitController.tags = ["AssetManager"];

export default deployConduitController;
