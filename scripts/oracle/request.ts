import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { ethers } from "ethers";
import { time } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import fs from "fs";
import path from "path";
import "dotenv/config";
import abi from "../scripts/trigger/abi.json";
import {
  SecretsManager,
  SubscriptionManager,
  decodeResult,
  createGist,
} from "@chainlink/functions-toolkit";

describe("Trigger", function () {
  describe("Request", function () {
    // happy case

    const routerAddress = "0xb83E47C2bC239B3bf370bc41e1459A34b41238D0";
    const linkTokenAddress = "0x779877A7B0D9E8603169DdbD7836e478b4624789";
    const donId = "fun-ethereum-sepolia-1";
    // const gatewayUrls = ["https://01.functions-gateway.testnet.chain.link/", "https://02.functions-gateway.testnet.chain.link/"];
    const source = fs
      .readFileSync(path.resolve(__dirname, "../scripts/trigger/source.js"))
      .toString();
    const user = "0xe7045038b976d147F8A874693971563122F81504";
    const args = [
      "0xe7045038b976d147f8a874693971563122f81504",
      "1714642629",
      "1719913029",
    ];
    const secrets: any = { apiKey: process.env.MORALIS_API_KEY };
    const gitApiKey: any = process.env.GITHUB_API_KEY;
    const gasLimit = 300000;
    const subscriptionId = process.env.SUBSCRIPTION_ID;
    const rpcUrl = process.env.SEPOLIA_RPC;
    const provider = new ethers.providers.JsonRpcProvider(rpcUrl);
    const privateKey: any = process.env.PRIVATE_KEY;
    const wallet = new ethers.Wallet(privateKey);
    const signer: any = wallet.connect(provider);
    // const will = process.env.WILL_ADDRESS;

    it("request", async function () {
      const triggerContract = new ethers.Contract(
        process.env.TRIGGER_ADDRESS as string,
        abi,
        signer
      );

      const secretsManager = new SecretsManager({
        signer: signer,
        functionsRouterAddress: routerAddress,
        donId: donId,
      });

      await secretsManager.initialize();
      const encryptedSecretsObj = await secretsManager.encryptSecrets(secrets);
      const gistURL = await createGist(
        gitApiKey,
        JSON.stringify(encryptedSecretsObj)
      );
      const encryptedSecretsUrls = await secretsManager.encryptSecretsUrls([
        gistURL,
      ]);
      console.log("encryptedSecretsUrls", encryptedSecretsUrls);
      // Initialize and return SubscriptionManager
      const subscriptionManager = new SubscriptionManager({
        signer: signer,
        linkTokenAddress: linkTokenAddress,
        functionsRouterAddress: routerAddress,
      });
      await subscriptionManager.initialize();

      // estimate costs in Juels
      const gasPriceWei: any = await signer.getGasPrice(); // get gasPrice in wei

      const estimatedCostInJuels =
        await subscriptionManager.estimateFunctionsRequestCost({
          donId: donId, // ID of the DON to which the Functions request will be sent
          subscriptionId: subscriptionId, // Subscription ID
          callbackGasLimit: gasLimit, // Total gas used by the consumer contract's callback
          gasPriceWei: BigInt(gasPriceWei), // Gas price in gWei
        });

      console.log(
        `Fulfillment cost estimated to ${ethers.utils.formatEther(
          estimatedCostInJuels
        )} LINK`
      );

      // const transaction = await triggerContract.sendRequest(args, will);
      // console.log(`\n✅ Functions request sent! Transaction hash ${transaction.hash}. Waiting for a response...`);
    });
  });
});
