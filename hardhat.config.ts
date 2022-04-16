import "@nomiclabs/hardhat-waffle";
import dotenv from "dotenv";
dotenv.config();
import "@nomiclabs/hardhat-etherscan";
import { task } from "hardhat/config";
import { HardhatUserConfig } from "hardhat/config";
// This adds support for typescript paths mappings
import "tsconfig-paths/register";
import '@typechain/hardhat'
import '@nomiclabs/hardhat-ethers'

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const config: HardhatUserConfig = {
  solidity: "0.8.13",
  networks: {
    goerli: {
      url: process.env.GOERLI_INFURIA_PROVIDER,
      accounts: [process.env.GOERLI_PRIVATE_KEY as string],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
export default config;
