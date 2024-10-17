import { expect } from "chai";
import { ethers } from "hardhat";

describe("AssetManager", function () {
  const RPC: string = process.env.RPC as string;
  const PRIVATE_KEY: string = process.env.PRIVATE_KEY as string;

  const provider = new ethers.JsonRpcProvider(RPC);
  const wallet = new ethers.Wallet(PRIVATE_KEY);

  async function deployContract() {
    console.log(await provider.getBalance(wallet.address));
  }

  it("deployment", async () => {
    deployContract();
  });
});
