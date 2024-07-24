import { HardhatUserConfig } from "hardhat/config";
import * as dotenv from "dotenv";
import "@nomicfoundation/hardhat-toolbox";

dotenv.config();
//api key
const API_KEY = process.env.API_KEY || "api key";
//etherscan api key
const ETHERSCAN_KEY = process.env.ETHERSCAN_KEY || "etherscan key";

//private key and mnemonic
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const MNEMONIC = process.env.MNEMONIC || "mnemonic";

const configNetwork = {
  mainnet:
    process.env.MAINNET_RPC_URL ||
    `https://eth-mainnet.g.alchemy.com/v2/${API_KEY}`,
  sepolia:
    process.env.SEPOLIA_RPC_URL ||
    `https://eth-sepolia.g.alchemy.com/v2/${API_KEY}`,
};

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  networks: {
    hardhat: {},
    localhost: {
      url: "https://127.0.0.1:8545",
    },
    mainnet: {
      url: configNetwork.mainnet,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : { mnemonic: MNEMONIC },
    },

    sepolia: {
      url: configNetwork.sepolia,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : { mnemonic: MNEMONIC },
    },
  },
  etherscan: {
    apiKey: {
      sepolia: ETHERSCAN_KEY,
    },
  },
};

export default config;
