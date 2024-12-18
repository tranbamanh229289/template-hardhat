import { Contract, ethers, Wallet } from "ethers";

const metadata: Record<
  string,
  { abi: ethers.InterfaceAbi; bytecode: { object: string } }
> = {
  WETH: WETHMetadata,
  ERC20: ERC20Metadata,
};

/* deploy contract */
export async function deployContract(
  tagName: string,
  arg: any[],
  wallet: Wallet
): Promise<string> {
  const abi = metadata[tagName].abi;
  const bytecode = metadata[tagName].bytecode;
  const contractFactory = new ethers.ContractFactory(abi, bytecode, wallet);
  const contract = await contractFactory.deploy(...arg);
  console.log("start deploying contract");
  await contract.waitForDeployment();
  const address = await contract.getAddress();
  console.log("contract is deployed at", address);
  return address;
}

export async function getContract(
  tagName: string,
  contractAddress: string,
  wallet: Wallet
): Promise<Contract> {
  const abi = metadata[tagName].abi;
  return new ethers.Contract(contractAddress, abi, wallet);
}
export async function encodeFunctionData(
  tagName: string,
  functionName: string,
  data: any[]
): Promise<string> {
  const abi = metadata[tagName].abi;
  let iface = new ethers.Interface(abi);
  return iface.encodeFunctionData(functionName, data);
}
