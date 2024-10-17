import { HardhatUserConfig } from "hardhat/config";
import * as dotenv from "dotenv";
import "@nomicfoundation/hardhat-toolbox";

dotenv.config();

//API key verify
const API_KEY_ETHERSCAN = process.env.API_KEY_ETHERSCAN as string;
const API_KEY_ARBISCAN = process.env.API_KEY_ARBISCAN as string;
const API_KEY_BSCSCAN = process.env.API_KEY_BSCSCAN as string;
const API_KEY_BASESCAN = process.env.API_KEY_BASESCAN as string;
const API_KEY_POLYGONSCAN = process.env.API_KEY_POLYGONSCAN as string;
const API_KEY_SNOWTRACE = process.env.API_KEY_SNOWTRACE as string;
const API_KEY_BLASTSCAN = process.env.API_KEY_BLASTSCAN as string;
const API_KEY_OPTIMISMSCAN = process.env.API_KEY_OPTIMISMSCAN as string;

//Private key and mnemonic
const PRIVATE_KEY = process.env.PRIVATE_KEY as string;

//Config network
const configNetwork = {
  hardhat: "https://127.0.0.1:8545",
  mainnet: "https://ethereum-rpc.publicnode.com",
  arbitrum: "https://arb1.arbitrum.io/rpc",
  bsc: "https://bsc-dataseed-public.bnbchain.org",
  base: "https://mainnet.base.org",
  polygon: "https://polygon-rpc.com",
  blast: "https://rpc.blast.io",
  avalanche: "https://avalanche-c-chain-rpc.publicnode.com",
  optimism: "https://mainnet.optimism.io",
  sepolia: "https://sepolia.drpc.org",
  arbitrum_sepolia: "https://sepolia-rollup.arbitrum.io/rpc",
  bsc_testnet: "https://bsc-testnet-dataseed.bnbchain.org",
  base_sepolia: "https://sepolia.base.org",
  polygon_amoy: "https://rpc-amoy.polygon.technology",
  blast_sepolia: "https://sepolia.blast.io",
  avalanche_fuji: "https://avalanche-fuji-c-chain-rpc.publicnode.com",
  optimism_sepolia: "https://sepolia.optimism.io",
};

//Config hardhat
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
      url: configNetwork.hardhat,
    },
    mainnet: {
      url: configNetwork.mainnet,
      accounts: [PRIVATE_KEY],
    },
    arbitrum: {
      url: configNetwork.arbitrum,
      accounts: [PRIVATE_KEY],
    },
    bsc: {
      url: configNetwork.bsc,
      accounts: [PRIVATE_KEY],
    },
    base: {
      url: configNetwork.base,
      accounts: [PRIVATE_KEY],
    },
    polygon: {
      url: configNetwork.polygon,
      accounts: [PRIVATE_KEY],
    },
    blast: {
      url: configNetwork.blast,
      accounts: [PRIVATE_KEY],
    },
    avalanche: {
      url: configNetwork.avalanche,
      accounts: [PRIVATE_KEY],
    },
    optimism: {
      url: configNetwork.optimism,
      accounts: [PRIVATE_KEY],
    },
    eth_sepolia: {
      url: configNetwork.sepolia,
      accounts: [PRIVATE_KEY],
    },
    arbitrum_sepolia: {
      url: configNetwork.arbitrum_sepolia,
      accounts: [PRIVATE_KEY],
    },
    bsc_testnet: {
      url: configNetwork.bsc_testnet,
      accounts: [PRIVATE_KEY],
    },
    base_sepolia: {
      url: configNetwork.base_sepolia,
      accounts: [PRIVATE_KEY],
    },
    polygon_amoy: {
      url: configNetwork.polygon_amoy,
      accounts: [PRIVATE_KEY],
    },
    blast_sepolia: {
      url: configNetwork.blast_sepolia,
      accounts: [PRIVATE_KEY],
    },
    avalanche_fuji: {
      url: configNetwork.avalanche_fuji,
      accounts: [PRIVATE_KEY],
    },
    optimism_sepolia: {
      url: configNetwork.optimism_sepolia,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      mainnet: API_KEY_ETHERSCAN,
      arbitrum: API_KEY_ARBISCAN,
      bsc: API_KEY_BSCSCAN,
      base: API_KEY_BASESCAN,
      polygon: API_KEY_POLYGONSCAN,
      blast: API_KEY_BLASTSCAN,
      avalanche: API_KEY_SNOWTRACE,
      optimism: API_KEY_OPTIMISMSCAN,
      eth_sepolia: API_KEY_ETHERSCAN,
      arbitrum_sepolia: API_KEY_ARBISCAN,
      bsc_testnet: API_KEY_BSCSCAN,
      base_sepolia: API_KEY_BASESCAN,
      polygon_amoy: API_KEY_POLYGONSCAN,
      blast_sepolia: API_KEY_BLASTSCAN,
      avalanche_fuji: API_KEY_SNOWTRACE,
      optimism_sepolia: API_KEY_OPTIMISMSCAN,
    },
  },
};

export default config;
